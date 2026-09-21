const i18n = require('./pharmsecure-i18n-utils');
async function languageMiddleware(req, res, next) {
  if (req.query.lang && i18n.isValidLanguage(req.query.lang)) req.language = req.query.lang;
  else if (req.headers['accept-language']?.includes('fr')) req.language = 'fr';
  else req.language = 'en';
  res.setHeader('X-Language', req.language);
  next();
}
function sendSuccess(res, data, message, language = 'en', statusCode = 200) {
  const response = { success: true, language, data };
  if (message) response.message = message;
  res.status(statusCode).json(response);
}
function sendError(res, error, statusCode = 400, language = 'en') {
  res.status(statusCode).json({ success: false, language, error });
}
module.exports = { languageMiddleware, sendSuccess, sendError };
