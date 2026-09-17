const { Pool } = require('pg');

// Use DATABASE_URL for production (Render), or individual env vars for local dev
const pool = new Pool({
  connectionString: process.env.DATABASE_URL || `postgresql://${process.env.DB_USER || 'pharmsecure_user'}:${process.env.DB_PASSWORD || 'pharmsecure_password_123'}@${process.env.DB_HOST || 'localhost'}:${process.env.DB_PORT || 5432}/${process.env.DB_NAME || 'pharmsecure'}`,
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
});

module.exports = pool;
