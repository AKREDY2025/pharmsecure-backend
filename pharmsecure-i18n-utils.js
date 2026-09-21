const pool = require('./db');
async function getLabel(keyName, language = 'en') {
  const result = await pool.query('SELECT en, fr FROM i18n_keys WHERE key_name = $1', [keyName]);
  if (result.rows.length === 0) return keyName;
  return language === 'fr' ? result.rows[0].fr : result.rows[0].en;
}
async function getTranslation(resourceType, resourceId, field, language = 'en') {
  const result = await pool.query('SELECT text FROM translations WHERE resource_type = $1 AND resource_id = $2 AND field_name = $3 AND language = $4', [resourceType, resourceId, field, language]);
  return result.rows.length > 0 ? result.rows[0].text : null;
}
async function setTranslation(resourceType, resourceId, field, language, text) {
  const result = await pool.query('INSERT INTO translations (resource_type, resource_id, field_name, language, text) VALUES ($1, $2, $3, $4, $5) ON CONFLICT (resource_type, resource_id, language, field_name) DO UPDATE SET text = $5 RETURNING *', [resourceType, resourceId, field, language, text]);
  return result.rows[0];
}
async function getPharmacyConfig(language = 'en') {
  const result = await pool.query('SELECT id, CASE WHEN $1 = \'fr\' THEN name_fr ELSE name_en END as name, address, phone, email FROM pharmacy_config LIMIT 1', [language]);
  return result.rows[0] || null;
}
async function getUserLanguage(userId) {
  const result = await pool.query('SELECT language FROM users WHERE id = $1', [userId]);
  return result.rows[0]?.language || 'en';
}
async function setUserLanguage(userId, language) {
  await pool.query('UPDATE users SET language = $1 WHERE id = $2', [language, userId]);
  return true;
}
function getAvailableLanguages() { return ['en', 'fr']; }
function isValidLanguage(language) { return getAvailableLanguages().includes(language); }
module.exports = { getLabel, getTranslation, setTranslation, getPharmacyConfig, getUserLanguage, setUserLanguage, getAvailableLanguages, isValidLanguage };
