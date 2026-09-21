const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const pool = require('../db');
const i18n = require('../pharmsecure-i18n-utils');
const { languageMiddleware, sendSuccess, sendError } = require('../pharmsecure-language-middleware');
const router = express.Router();
router.use(languageMiddleware);
router.post('/login', async (req, res) => {
  const { username, password, language = req.language } = req.body;
  if (!username || !password) return sendError(res, 'Credentials required', 400, language);
  const result = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
  if (result.rows.length === 0) return sendError(res, 'Invalid credentials', 401, language);
  const user = result.rows[0];
  const match = await bcrypt.compare(password, user.password_hash);
  if (!match) return sendError(res, 'Invalid credentials', 401, language);
  const token = jwt.sign({ id: user.id, username: user.username, role: user.role }, process.env.JWT_SECRET || 'key', { expiresIn: '24h' });
  await i18n.setUserLanguage(user.id, language);
  const pharmacy = await i18n.getPharmacyConfig(language);
  sendSuccess(res, { token, user: { id: user.id, username, email: user.email, role: user.role, language }, pharmacy }, 'Login successful');
});
router.get('/languages', (req, res) => {
  sendSuccess(res, { languages: i18n.getAvailableLanguages() });
});
module.exports = router;
