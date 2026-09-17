require("dotenv").config();
const express = require('express');
const cors = require("cors");
const pool = require('./db');
const jwt = require('jsonwebtoken');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(cors());

// Middleware to verify token
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.sendStatus(401);
  next();
};

// Routes
const authRoutes = require('./routes/auth');
const pendingOrdersRoutes = require('./routes/pending-orders');
const productsRoutes = require('./routes/products');
const batchesRoutes = require('./routes/batches');
const dashboardRoutes = require('./routes/dashboard');
const reportsRoutes = require('./routes/reports');
const inventoryRoutes = require('./routes/inventory');
const refundsRoutes = require('./routes/refunds');
const staffRoutes = require('./routes/staff');
const printingRoutes = require('./routes/printing');

app.use('/api/auth', authRoutes);
app.use('/api/pending-orders', pendingOrdersRoutes);
app.use('/api/products', productsRoutes);
app.use('/api/batches', batchesRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/reports', reportsRoutes);
app.use('/api/inventory', inventoryRoutes);
app.use('/api/refunds', refundsRoutes);
app.use('/api/staff', staffRoutes);
app.use('/api/printing', printingRoutes);

// Migration endpoint (admin only)
app.get('/api/migrate', authenticateToken, async (req, res) => {
  try {
    const { createTables } = require('./migrations/001_phase5g_extended');
    await createTables();
    res.json({ success: true, message: 'Migration completed' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ success: false, message: 'Endpoint not found' });
});

// Test database connection and start server
pool.query('SELECT NOW()')
  .then(() => {
    console.log('Database connected successfully');
    app.listen(PORT, () => {
      console.log(`PharmSecure Backend running on port ${PORT}`);
    });
  })
  .catch(err => {
    console.error('Database connection failed:', err);
    process.exit(1);
  });

module.exports = app;
