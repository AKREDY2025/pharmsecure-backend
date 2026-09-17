const express = require('express');
const router = express.Router();
const pool = require('../db');
const { authenticateToken } = require('../middleware/auth');

// Get sales by date range
router.get('/sales', authenticateToken, async (req, res) => {
  try {
    const { start_date, end_date } = req.query;
    
    if (!start_date || !end_date) {
      return res.status(400).json({ success: false, message: 'start_date and end_date required' });
    }

    const result = await pool.query(`
      SELECT 
        po.id,
        po.created_at,
        po.customer_name,
        po.customer_phone,
        u.username as seller_name,
        po.subtotal,
        po.tax,
        po.total_amount,
        po.status
      FROM pending_orders po
      LEFT JOIN users u ON u.id = po.seller_id
      WHERE DATE(po.created_at) >= $1 
      AND DATE(po.created_at) <= $2
      ORDER BY po.created_at DESC
    `, [start_date, end_date]);

    res.json({ success: true, data: { sales: result.rows } });
  } catch (error) {
    console.error('Sales report error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch sales', error: error.message });
  }
});

// Get product profitability analysis
router.get('/product-profitability', authenticateToken, async (req, res) => {
  try {
    const { start_date, end_date } = req.query;
    
    if (!start_date || !end_date) {
      return res.status(400).json({ success: false, message: 'start_date and end_date required' });
    }

    const result = await pool.query(`
      SELECT 
        p.id,
        p.name,
        p.sku,
        COALESCE(p.unit_price::TEXT, '0')::NUMERIC as unit_price,
        COALESCE(SUM((item->>'quantity')::INT), 0) as total_qty_sold,
        COALESCE(SUM((item->>'line_total')::NUMERIC), 0) as total_revenue
      FROM products p
      LEFT JOIN pending_orders po ON po.status = 'COMPLETED' 
        AND DATE(po.created_at) >= $1 
        AND DATE(po.created_at) <= $2
      LEFT JOIN jsonb_array_elements(po.items_json) as item ON (item->>'product_id')::INT = p.id
      GROUP BY p.id, p.name, p.sku, p.unit_price
      ORDER BY total_revenue DESC
    `, [start_date, end_date]);

    res.json({ success: true, data: { products: result.rows } });
  } catch (error) {
    console.error('Profitability error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch profitability', error: error.message });
  }
});

// Get summary by date range
router.get('/summary', authenticateToken, async (req, res) => {
  try {
    const { start_date, end_date } = req.query;
    
    if (!start_date || !end_date) {
      return res.status(400).json({ success: false, message: 'start_date and end_date required' });
    }

    const result = await pool.query(`
      SELECT 
        COUNT(*) as transaction_count,
        ROUND(SUM(CAST(total_amount AS NUMERIC)), 2) as total_revenue,
        ROUND(AVG(CAST(total_amount AS NUMERIC)), 2) as avg_order_value,
        MAX(CAST(total_amount AS NUMERIC)) as max_order,
        MIN(CAST(total_amount AS NUMERIC)) as min_order,
        ROUND(SUM(CAST(tax AS NUMERIC)), 2) as total_tax,
        ROUND(SUM(CAST(subtotal AS NUMERIC)), 2) as total_subtotal
      FROM pending_orders 
      WHERE status = 'COMPLETED' 
      AND DATE(created_at) >= $1 
      AND DATE(created_at) <= $2
    `, [start_date, end_date]);

    res.json({ success: true, data: { summary: result.rows[0] || {} } });
  } catch (error) {
    console.error('Summary error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch summary', error: error.message });
  }
});

// Get seller report
router.get('/sellers', authenticateToken, async (req, res) => {
  try {
    const { start_date, end_date } = req.query;
    
    if (!start_date || !end_date) {
      return res.status(400).json({ success: false, message: 'start_date and end_date required' });
    }

    const result = await pool.query(`
      SELECT 
        po.seller_id,
        COALESCE(u.username, 'Unknown') as seller_name,
        COUNT(*) as transaction_count,
        ROUND(SUM(CAST(po.total_amount AS NUMERIC)), 2) as total_revenue,
        ROUND(AVG(CAST(po.total_amount AS NUMERIC)), 2) as avg_order_value
      FROM pending_orders po
      LEFT JOIN users u ON u.id = po.seller_id
      WHERE po.status = 'COMPLETED'
      AND DATE(po.created_at) >= $1 
      AND DATE(po.created_at) <= $2
      GROUP BY po.seller_id, u.username
      ORDER BY total_revenue DESC
    `, [start_date, end_date]);

    res.json({ success: true, data: { sellers: result.rows } });
  } catch (error) {
    console.error('Seller report error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch seller report', error: error.message });
  }
});

module.exports = router;
