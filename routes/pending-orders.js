const express = require('express');
const router = express.Router();
const pool = require('../db');
const { authenticateToken } = require('../middleware/auth');

router.post('/', authenticateToken, async (req, res) => {
  const { customer_name, customer_phone } = req.body;
  const seller_id = req.user.id;
  try {
    const result = await pool.query(
      'INSERT INTO pending_orders (seller_id, customer_name, customer_phone, status, subtotal, tax, total_amount, items_json) VALUES ($1, $2, $3, $4, 0, 0, 0, $5) RETURNING *',
      [seller_id, customer_name || 'Walk-in', customer_phone || null, 'DRAFT', JSON.stringify([])]
    );
    res.json({ success: true, data: { pending_order: result.rows[0] } });
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({ success: false, message: 'Failed to create order', error: error.message });
  }
});

router.get('/', authenticateToken, async (req, res) => {
  try {
    const query = req.user.role === 'cashier' 
      ? 'SELECT * FROM pending_orders WHERE status = $1 ORDER BY created_at DESC'
      : 'SELECT * FROM pending_orders WHERE seller_id = $1 ORDER BY created_at DESC';
    const params = req.user.role === 'cashier' ? ['READY_FOR_PAYMENT'] : [req.user.id];
    const result = await pool.query(query, params);
    res.json({ success: true, data: { orders: result.rows } });
  } catch (error) {
    console.error('Get orders error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch orders', error: error.message });
  }
});

router.put('/:id/items', authenticateToken, async (req, res) => {
  const { id } = req.params;
  const { action, batch_id, product_id, quantity } = req.body;
  if (action !== 'add') {
    return res.status(400).json({ success: false, message: 'Invalid action' });
  }
  try {
    const orderResult = await pool.query('SELECT * FROM pending_orders WHERE id = $1', [id]);
    if (orderResult.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }
    const order = orderResult.rows[0];
    const items = (typeof order.items_json === 'string') ? JSON.parse(order.items_json) : order.items_json || [];
    const productResult = await pool.query('SELECT unit_price FROM products WHERE id = $1', [product_id]);
    if (productResult.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Product not found' });
    }
    const unit_price = parseFloat(productResult.rows[0].unit_price);
    const line_total = unit_price * quantity;
    const newItem = {
      batch_id,
      product_id,
      product_name: (await pool.query('SELECT name FROM products WHERE id = $1', [product_id])).rows[0].name,
      quantity: parseInt(quantity),
      unit_price,
      line_total
    };
    items.push(newItem);
    const subtotal = items.reduce((sum, item) => sum + item.line_total, 0);
    const tax = subtotal * 0.15;
    const total = subtotal + tax;
    await pool.query(
      'UPDATE pending_orders SET items_json = $1, subtotal = $2, tax = $3, total_amount = $4 WHERE id = $5',
      [JSON.stringify(items), subtotal, tax, total, id]
    );
    res.json({ success: true, message: 'Item added' });
  } catch (error) {
    console.error('Add items error:', error);
    res.status(500).json({ success: false, message: 'Failed to add items', error: error.message });
  }
});

router.put('/:id/transfer', authenticateToken, async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      'UPDATE pending_orders SET status = $1 WHERE id = $2 RETURNING *',
      ['READY_FOR_PAYMENT', id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }
    res.json({ success: true, data: { order: result.rows[0] } });
  } catch (error) {
    console.error('Transfer error:', error);
    res.status(500).json({ success: false, message: 'Failed to transfer', error: error.message });
  }
});

router.get('/queue/cashier', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM pending_orders WHERE status = $1 ORDER BY created_at ASC',
      ['READY_FOR_PAYMENT']
    );
    res.json({ success: true, data: { queue: result.rows } });
  } catch (error) {
    console.error('Queue error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch queue', error: error.message });
  }
});

router.put('/:id/complete', authenticateToken, async (req, res) => {
  const { id } = req.params;
  const { payment_method, amount_paid } = req.body;
  try {
    const orderResult = await pool.query('SELECT * FROM pending_orders WHERE id = $1', [id]);
    if (orderResult.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }
    
    const order = orderResult.rows[0];
    const items = (typeof order.items_json === 'string') ? JSON.parse(order.items_json) : (order.items_json || []);
    const change_amount = parseFloat(amount_paid) - parseFloat(order.total_amount);
    const userId = req.user.id;

    // Reduce inventory for each item (optional - won't fail sale if this errors)
    if (items && Array.isArray(items)) {
      for (const item of items) {
        try {
          if (item.batch_id) {
            await pool.query(
              'UPDATE batches SET quantity_in_stock = quantity_in_stock - $1 WHERE id = $2',
              [parseInt(item.quantity) || 0, parseInt(item.batch_id)]
            );
            
            await pool.query(
              'INSERT INTO inventory_movements (batch_id, quantity_change, reason, user_id) VALUES ($1, $2, $3, $4)',
              [parseInt(item.batch_id), -(parseInt(item.quantity) || 0), 'SALE', userId]
            );
          }
        } catch (invErr) {
          console.warn('Inventory warning:', invErr.message);
        }
      }
    }

    // Mark order as completed
    await pool.query(
      'UPDATE pending_orders SET status = $1 WHERE id = $2',
      ['COMPLETED', id]
    );

    res.json({
      success: true,
      data: { sale_id: id, change_amount: change_amount.toFixed(2) }
    });
  } catch (error) {
    console.error('Complete error:', error);
    res.status(500).json({ success: false, message: 'Failed to complete sale', error: error.message });
  }
});

module.exports = router;
