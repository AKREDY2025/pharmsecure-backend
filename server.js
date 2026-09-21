require("dotenv").config();
const express = require('express');
const path = require('path');
const cors = require("cors");
const pool = require('./db');
const jwt = require('jsonwebtoken');
const { languageMiddleware } = require('./pharmsecure-language-middleware');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(cors());
app.use(languageMiddleware);

// Serve static files from public directory
app.use(express.static(path.join(__dirname, 'public')));

// Middleware to verify token
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.sendStatus(401);
  next();
};

// Routes with error handling
const routes = {
  auth: './routes/auth',
  pendingOrders: './routes/pending-orders',
  products: './routes/products',
  batches: './routes/batches',
  dashboard: './routes/dashboard',
  reports: './routes/reports',
  inventory: './routes/inventory',
  refunds: './routes/refunds',
  staff: './routes/staff',
  printing: './routes/printing',
};

const endpoints = {
  auth: '/api/auth',
  pendingOrders: '/api/pending-orders',
  products: '/api/products',
  batches: '/api/batches',
  dashboard: '/api/dashboard',
  reports: '/api/reports',
  inventory: '/api/inventory',
  refunds: '/api/refunds',
  staff: '/api/staff',
  printing: '/api/printing',
};

for (const [key, path] of Object.entries(routes)) {
  try {
    const router = require(path);
    app.use(endpoints[key], router);
    console.log(`✓ Loaded route: ${endpoints[key]}`);
  } catch (err) {
    console.error(`✗ Failed to load ${path}:`, err.message);
  }
}

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

// Serve index.html for root and any undefined routes (SPA fallback)
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
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
