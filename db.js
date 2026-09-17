const { Pool } = require('pg');

const pool = new Pool({
  user: process.env.DB_USER || 'pharmsecure_user',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'pharmsecure',
  password: process.env.DB_PASSWORD || 'pharmsecure_password_123',
  port: process.env.DB_PORT || 5432,
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
});

module.exports = pool;
