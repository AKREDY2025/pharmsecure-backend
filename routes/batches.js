const express = require('express');
const router = express.Router();
const pool = require('../db');
const { authenticateToken } = require('../middleware/auth');

// Get batches by product_id
router.get('/', authenticateToken, async (req, res) => {
  const { product_id } = req.query;

  if (!product_id) {
    return res.status(400).json({ success: false, message: 'product_id required' });
  }

  try {
    const result = await pool.query(
      'SELECT id, batch_number, quantity_in_stock as quantity_available, expiry_date, status FROM batches WHERE product_id = $1 ORDER BY created_at DESC',
      [product_id]
    );

    res.json({
      success: true,
      data: {
        batches: result.rows
      }
    });
  } catch (error) {
    console.error('Get batches error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch batches', error: error.message });
  }
});

module.exports = router;
