const express = require('express');
const router = express.Router();
const pool = require('../db');
const { authenticateToken } = require('../middleware/auth');

// Get current stock levels
router.get('/stock-levels', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        b.id,
        b.batch_number,
        p.id as product_id,
        p.name as product_name,
        p.sku,
        b.quantity_in_stock,
        p.reorder_level,
        b.expiry_date,
        CASE 
          WHEN b.quantity_in_stock <= p.reorder_level THEN 'LOW'
          WHEN b.expiry_date < NOW() THEN 'EXPIRED'
          WHEN b.expiry_date < NOW() + INTERVAL '30 days' THEN 'EXPIRING_SOON'
          ELSE 'OK'
        END as status
      FROM batches b
      JOIN products p ON b.product_id = p.id
      ORDER BY b.quantity_in_stock ASC
    `);

    res.json({ success: true, data: { stock_levels: result.rows } });
  } catch (error) {
    console.error('Stock levels error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch stock', error: error.message });
  }
});

// Get low stock alerts
router.get('/low-stock-alerts', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        b.id,
        b.batch_number,
        p.name,
        p.sku,
        b.quantity_in_stock,
        p.reorder_level,
        (p.reorder_level - b.quantity_in_stock) as shortage
      FROM batches b
      JOIN products p ON b.product_id = p.id
      WHERE b.quantity_in_stock <= p.reorder_level
      AND b.quantity_in_stock > 0
      ORDER BY shortage DESC
    `);

    res.json({ success: true, data: { alerts: result.rows, count: result.rows.length } });
  } catch (error) {
    console.error('Alerts error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch alerts', error: error.message });
  }
});

// Get expiring soon
router.get('/expiring-soon', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        b.id,
        b.batch_number,
        p.name,
        p.sku,
        b.quantity_in_stock,
        b.expiry_date,
        (b.expiry_date - NOW()) as days_until_expiry
      FROM batches b
      JOIN products p ON b.product_id = p.id
      WHERE b.expiry_date BETWEEN NOW() AND NOW() + INTERVAL '30 days'
      AND b.quantity_in_stock > 0
      ORDER BY b.expiry_date ASC
    `);

    res.json({ success: true, data: { expiring: result.rows } });
  } catch (error) {
    console.error('Expiring error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch expiring', error: error.message });
  }
});

// Get inventory movements (history)
router.get('/movements/:batch_id', authenticateToken, async (req, res) => {
  try {
    const { batch_id } = req.params;
    
    const result = await pool.query(`
      SELECT 
        im.id,
        im.quantity_change,
        im.reason,
        u.username as user_name,
        im.created_at
      FROM inventory_movements im
      LEFT JOIN users u ON im.user_id = u.id
      WHERE im.batch_id = $1
      ORDER BY im.created_at DESC
      LIMIT 50
    `, [batch_id]);

    res.json({ success: true, data: { movements: result.rows } });
  } catch (error) {
    console.error('Movements error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch movements', error: error.message });
  }
});

// Record inventory movement (manual adjustment)
router.post('/movement', authenticateToken, async (req, res) => {
  try {
    const { batch_id, quantity_change, reason } = req.body;
    const user_id = req.user.id;

    if (!batch_id || !quantity_change || !reason) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    // Record movement
    await pool.query(`
      INSERT INTO inventory_movements (batch_id, quantity_change, reason, user_id)
      VALUES ($1, $2, $3, $4)
    `, [batch_id, quantity_change, reason, user_id]);

    // Update batch stock
    await pool.query(`
      UPDATE batches SET quantity_in_stock = quantity_in_stock + $1
      WHERE id = $2
    `, [quantity_change, batch_id]);

    res.json({ success: true, message: 'Inventory movement recorded' });
  } catch (error) {
    console.error('Movement error:', error);
    res.status(500).json({ success: false, message: 'Failed to record movement', error: error.message });
  }
});

// Get inventory dashboard summary
router.get('/summary', authenticateToken, async (req, res) => {
  try {
    const [totalStock, lowStock, expiringSoon] = await Promise.all([
      pool.query(`SELECT SUM(quantity_in_stock)::INT as total FROM batches`),
      pool.query(`SELECT COUNT(*) as count FROM batches b JOIN products p ON b.product_id = p.id WHERE b.quantity_in_stock <= p.reorder_level AND b.quantity_in_stock > 0`),
      pool.query(`SELECT COUNT(*) as count FROM batches WHERE expiry_date BETWEEN NOW() AND NOW() + INTERVAL '30 days' AND quantity_in_stock > 0`)
    ]);

    res.json({ success: true, data: {
      total_items_in_stock: totalStock.rows[0].total || 0,
      low_stock_count: lowStock.rows[0].count || 0,
      expiring_soon_count: expiringSoon.rows[0].count || 0
    }});
  } catch (error) {
    console.error('Summary error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch summary', error: error.message });
  }
});

module.exports = router;
