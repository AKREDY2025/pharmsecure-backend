const express = require('express');
const router = express.Router();
const pool = require('../db');
const { authenticateToken } = require('../middleware/auth');

// Get refund requests (pending approval)
router.get('/pending', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        r.id,
        r.order_id,
        po.customer_name,
        po.total_amount,
        r.refund_amount,
        r.refund_reason,
        r.refund_status,
        r.created_at,
        u.username as seller_name
      FROM refunds r
      JOIN pending_orders po ON r.order_id = po.id
      LEFT JOIN users u ON po.seller_id = u.id
      WHERE r.refund_status = 'PENDING'
      ORDER BY r.created_at DESC
    `);

    res.json({ success: true, data: { pending_refunds: result.rows } });
  } catch (error) {
    console.error('Pending refunds error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch pending refunds', error: error.message });
  }
});

// Get all refunds with history
router.get('/history', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        r.id,
        r.order_id,
        po.customer_name,
        po.total_amount,
        r.refund_amount,
        r.refund_reason,
        r.refund_status,
        r.created_at,
        r.processed_at,
        u.username as processed_by
      FROM refunds r
      JOIN pending_orders po ON r.order_id = po.id
      LEFT JOIN users u ON r.approved_by = u.id
      ORDER BY r.created_at DESC
      LIMIT 100
    `);

    res.json({ success: true, data: { refunds: result.rows } });
  } catch (error) {
    console.error('Refund history error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch refund history', error: error.message });
  }
});

// Request refund
router.post('/request', authenticateToken, async (req, res) => {
  try {
    const { order_id, refund_reason, return_items, notes } = req.body;

    if (!order_id || !refund_reason) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    // Get order details
    const orderResult = await pool.query('SELECT * FROM pending_orders WHERE id = $1', [order_id]);
    if (orderResult.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    const order = orderResult.rows[0];

    // Create refund record
    const refundResult = await pool.query(`
      INSERT INTO refunds (order_id, refund_amount, refund_reason, refund_status, notes)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `, [order_id, order.total_amount, refund_reason, 'PENDING', notes || '']);

    const refund_id = refundResult.rows[0].id;

    // Insert return items
    if (return_items && return_items.length > 0) {
      for (const item of return_items) {
        await pool.query(`
          INSERT INTO return_items (refund_id, product_id, quantity, reason)
          VALUES ($1, $2, $3, $4)
        `, [refund_id, item.product_id, item.quantity, item.reason]);
      }
    }

    res.json({ success: true, data: { refund: refundResult.rows[0] }, message: 'Refund request created' });
  } catch (error) {
    console.error('Request refund error:', error);
    res.status(500).json({ success: false, message: 'Failed to request refund', error: error.message });
  }
});

// Approve refund
router.put('/:id/approve', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { notes } = req.body;
    const user_id = req.user.id;

    const result = await pool.query(`
      UPDATE refunds 
      SET refund_status = $1, approved_by = $2, approved_at = NOW(), notes = $3, updated_at = NOW()
      WHERE id = $4
      RETURNING *
    `, ['APPROVED', user_id, notes || '', id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Refund not found' });
    }

    res.json({ success: true, data: { refund: result.rows[0] }, message: 'Refund approved' });
  } catch (error) {
    console.error('Approve refund error:', error);
    res.status(500).json({ success: false, message: 'Failed to approve refund', error: error.message });
  }
});

// Reject refund
router.put('/:id/reject', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { reason } = req.body;

    const result = await pool.query(`
      UPDATE refunds 
      SET refund_status = $1, notes = $2, updated_at = NOW()
      WHERE id = $3
      RETURNING *
    `, ['REJECTED', reason || '', id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Refund not found' });
    }

    res.json({ success: true, data: { refund: result.rows[0] }, message: 'Refund rejected' });
  } catch (error) {
    console.error('Reject refund error:', error);
    res.status(500).json({ success: false, message: 'Failed to reject refund', error: error.message });
  }
});

// Process refund (complete the transaction)
router.put('/:id/process', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(`
      UPDATE refunds 
      SET refund_status = $1, processed_at = NOW(), updated_at = NOW()
      WHERE id = $2 AND refund_status = $3
      RETURNING *
    `, ['COMPLETED', id, 'APPROVED']);

    if (result.rows.length === 0) {
      return res.status(400).json({ success: false, message: 'Refund must be approved first' });
    }

    res.json({ success: true, data: { refund: result.rows[0] }, message: 'Refund processed' });
  } catch (error) {
    console.error('Process refund error:', error);
    res.status(500).json({ success: false, message: 'Failed to process refund', error: error.message });
  }
});

// Get return items for a refund
router.get('/:id/items', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(`
      SELECT 
        ri.id,
        ri.product_id,
        p.name as product_name,
        p.sku,
        ri.quantity,
        ri.reason
      FROM return_items ri
      JOIN products p ON ri.product_id = p.id
      WHERE ri.refund_id = $1
    `, [id]);

    res.json({ success: true, data: { items: result.rows } });
  } catch (error) {
    console.error('Get return items error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch return items', error: error.message });
  }
});

// Get refund statistics
router.get('/stats/summary', authenticateToken, async (req, res) => {
  try {
    const [pending, approved, rejected, totalAmount] = await Promise.all([
      pool.query(`SELECT COUNT(*) as count FROM refunds WHERE refund_status = 'PENDING'`),
      pool.query(`SELECT COUNT(*) as count FROM refunds WHERE refund_status = 'APPROVED'`),
      pool.query(`SELECT COUNT(*) as count FROM refunds WHERE refund_status = 'REJECTED'`),
      pool.query(`SELECT ROUND(SUM(refund_amount), 2) as total FROM refunds WHERE refund_status = 'COMPLETED'`)
    ]);

    res.json({ success: true, data: {
      pending_count: pending.rows[0].count || 0,
      approved_count: approved.rows[0].count || 0,
      rejected_count: rejected.rows[0].count || 0,
      total_refunded: totalAmount.rows[0].total || 0
    }});
  } catch (error) {
    console.error('Stats error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch stats', error: error.message });
  }
});

module.exports = router;
