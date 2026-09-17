const express = require('express');
const router = express.Router();
const pool = require('../db');
const { authenticateToken } = require('../middleware/auth');

// Get today's summary
router.get('/summary', authenticateToken, async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    
    const result = await pool.query(`
      SELECT 
        COUNT(*) as transaction_count,
        ROUND(SUM(CAST(total_amount AS NUMERIC)), 2) as total_revenue,
        ROUND(AVG(CAST(total_amount AS NUMERIC)), 2) as avg_order_value,
        MAX(CAST(total_amount AS NUMERIC)) as max_order,
        MIN(CAST(total_amount AS NUMERIC)) as min_order
      FROM pending_orders 
      WHERE status = 'COMPLETED' 
      AND DATE(created_at) = $1
    `, [today]);

    const summary = result.rows[0] || {
      transaction_count: 0,
      total_revenue: 0,
      avg_order_value: 0,
      max_order: 0,
      min_order: 0
    };

    res.json({ success: true, data: summary });
  } catch (error) {
    console.error('Summary error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch summary', error: error.message });
  }
});

// Get hourly sales breakdown for today
router.get('/sales-today', authenticateToken, async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    
    const result = await pool.query(`
      SELECT 
        EXTRACT(HOUR FROM created_at) as hour,
        COUNT(*) as transaction_count,
        ROUND(SUM(CAST(total_amount AS NUMERIC)), 2) as revenue
      FROM pending_orders 
      WHERE status = 'COMPLETED' 
      AND DATE(created_at) = $1
      GROUP BY EXTRACT(HOUR FROM created_at)
      ORDER BY hour
    `, [today]);

    res.json({ success: true, data: { hourly_sales: result.rows } });
  } catch (error) {
    console.error('Sales today error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch sales', error: error.message });
  }
});

// Get revenue trend (days parameter: 7, 30, etc)
router.get('/revenue-trend', authenticateToken, async (req, res) => {
  try {
    const days = parseInt(req.query.days) || 30;
    
    const result = await pool.query(`
      SELECT 
        DATE(created_at) as date,
        COUNT(*) as transaction_count,
        ROUND(SUM(CAST(total_amount AS NUMERIC)), 2) as revenue
      FROM pending_orders 
      WHERE status = 'COMPLETED'
      AND created_at >= NOW() - INTERVAL '1 day' * $1
      GROUP BY DATE(created_at)
      ORDER BY date
    `, [days]);

    res.json({ success: true, data: { trend: result.rows } });
  } catch (error) {
    console.error('Trend error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch trend', error: error.message });
  }
});

// Get top products
router.get('/top-products', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        p.name,
        p.id,
        COALESCE(SUM((item->>'quantity')::INT), 0) as total_qty,
        COALESCE(ROUND(SUM((item->>'line_total')::NUMERIC), 2), 0) as total_revenue,
        ROUND((item->>'unit_price')::NUMERIC, 2) as unit_price
      FROM pending_orders po,
      jsonb_array_elements(po.items_json) as item
      JOIN products p ON p.id = (item->>'product_id')::INT
      WHERE po.status = 'COMPLETED'
      AND DATE(po.created_at) = DATE(NOW())
      GROUP BY p.id, p.name, (item->>'unit_price')
      ORDER BY total_qty DESC
      LIMIT 10
    `);

    res.json({ success: true, data: { top_products: result.rows } });
  } catch (error) {
    console.error('Top products error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch top products', error: error.message });
  }
});

// Get seller performance
router.get('/seller-performance', authenticateToken, async (req, res) => {
  try {
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
      AND DATE(po.created_at) = DATE(NOW())
      GROUP BY po.seller_id, u.username
      ORDER BY total_revenue DESC
    `);

    res.json({ success: true, data: { sellers: result.rows } });
  } catch (error) {
    console.error('Seller performance error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch seller performance', error: error.message });
  }
});

module.exports = router;
