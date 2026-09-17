const express = require('express');
const router = express.Router();
const pool = require('../db');
const { authenticateToken } = require('../middleware/auth');
const bcrypt = require('bcrypt');

// Get all users
router.get('/users', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        u.id,
        u.username,
        u.email,
        u.status,
        r.name as role_name,
        r.id as role_id,
        u.created_at
      FROM users u
      LEFT JOIN roles r ON u.role_id = r.id
      ORDER BY u.created_at DESC
    `);

    res.json({ success: true, data: { users: result.rows } });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch users', error: error.message });
  }
});

// Get all roles
router.get('/roles', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT id, name, description, permissions
      FROM roles
      ORDER BY name
    `);

    res.json({ success: true, data: { roles: result.rows } });
  } catch (error) {
    console.error('Get roles error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch roles', error: error.message });
  }
});

// Get audit log
router.get('/audit-log', authenticateToken, async (req, res) => {
  try {
    const limit = req.query.limit || 100;
    const result = await pool.query(`
      SELECT 
        ual.id,
        ual.user_id,
        u.username as actor,
        ual.action,
        ual.details,
        ual.created_at
      FROM user_audit_log ual
      LEFT JOIN users u ON ual.user_id = u.id
      ORDER BY ual.created_at DESC
      LIMIT $1
    `, [limit]);

    res.json({ success: true, data: { audit_log: result.rows } });
  } catch (error) {
    console.error('Get audit log error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch audit log', error: error.message });
  }
});

// Create new user
router.post('/users', authenticateToken, async (req, res) => {
  try {
    const { username, email, password, role_id } = req.body;

    if (!username || !email || !password || !role_id) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    // Check if user exists
    const existCheck = await pool.query('SELECT id FROM users WHERE username = $1 OR email = $2', [username, email]);
    if (existCheck.rows.length > 0) {
      return res.status(400).json({ success: false, message: 'Username or email already exists' });
    }

    // Hash password
    const password_hash = await bcrypt.hash(password, 10);

    // Create user
    const result = await pool.query(`
      INSERT INTO users (username, email, password_hash, role_id, status)
      VALUES ($1, $2, $3, $4, 'ACTIVE')
      RETURNING id, username, email, role_id, status, created_at
    `, [username, email, password_hash, role_id]);

    res.json({ success: true, data: { user: result.rows[0] }, message: 'User created successfully' });
  } catch (error) {
    console.error('Create user error:', error);
    res.status(500).json({ success: false, message: 'Failed to create user', error: error.message });
  }
});

// Update user
router.put('/users/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { username, email, role_id, status } = req.body;

    const result = await pool.query(`
      UPDATE users 
      SET username = COALESCE($1, username),
          email = COALESCE($2, email),
          role_id = COALESCE($3, role_id),
          status = COALESCE($4, status)
      WHERE id = $5
      RETURNING id, username, email, role_id, status, created_at
    `, [username || null, email || null, role_id || null, status || null, id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.json({ success: true, data: { user: result.rows[0] }, message: 'User updated successfully' });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({ success: false, message: 'Failed to update user', error: error.message });
  }
});

// Deactivate user
router.delete('/users/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(`
      UPDATE users 
      SET status = 'INACTIVE'
      WHERE id = $1
      RETURNING id, username, status
    `, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    res.json({ success: true, data: { user: result.rows[0] }, message: 'User deactivated' });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({ success: false, message: 'Failed to deactivate user', error: error.message });
  }
});

// Get stats
router.get('/stats', authenticateToken, async (req, res) => {
  try {
    const [totalUsers, activeUsers, usersByRole, recentActions] = await Promise.all([
      pool.query(`SELECT COUNT(*) as count FROM users`),
      pool.query(`SELECT COUNT(*) as count FROM users WHERE status = 'ACTIVE'`),
      pool.query(`SELECT r.name, COUNT(u.id) as count FROM users u LEFT JOIN roles r ON u.role_id = r.id GROUP BY r.name`),
      pool.query(`SELECT COUNT(*) as count FROM user_audit_log WHERE created_at > NOW() - INTERVAL '24 hours'`)
    ]);

    res.json({ success: true, data: {
      total_users: parseInt(totalUsers.rows[0].count) || 0,
      active_users: parseInt(activeUsers.rows[0].count) || 0,
      by_role: usersByRole.rows,
      recent_actions_24h: parseInt(recentActions.rows[0].count) || 0
    }});
  } catch (error) {
    console.error('Stats error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch stats', error: error.message });
  }
});

module.exports = router;

// Update role permissions
router.put('/roles/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { permissions } = req.body;

    if (!permissions) {
      return res.status(400).json({ success: false, message: 'Missing permissions' });
    }

    const result = await pool.query(`
      UPDATE roles 
      SET permissions = $1, updated_at = NOW()
      WHERE id = $2
      RETURNING id, name, permissions
    `, [JSON.stringify(permissions), id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Role not found' });
    }

    res.json({ success: true, data: { role: result.rows[0] }, message: 'Role permissions updated' });
  } catch (error) {
    console.error('Update role error:', error);
    res.status(500).json({ success: false, message: 'Failed to update role', error: error.message });
  }
});

