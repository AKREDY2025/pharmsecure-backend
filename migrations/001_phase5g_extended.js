const pool = require('../db');

const createTables = async () => {
  try {
    console.log('Creating Phase 5G-Extended tables...');

    // Sent emails table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS sent_emails (
        id SERIAL PRIMARY KEY,
        order_id INTEGER REFERENCES pending_orders(id),
        recipient_email VARCHAR(255),
        sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status VARCHAR(20)
      );
    `);
    console.log('✅ sent_emails table created');

    // Sent SMS table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS sent_sms (
        id SERIAL PRIMARY KEY,
        order_id INTEGER REFERENCES pending_orders(id),
        phone_number VARCHAR(20),
        sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status VARCHAR(20)
      );
    `);
    console.log('✅ sent_sms table created');

    // Message templates table
    await pool.query(`
      CREATE TABLE IF NOT EXISTS message_templates (
        id SERIAL PRIMARY KEY,
        type VARCHAR(20),
        name VARCHAR(100),
        subject VARCHAR(255),
        body TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ message_templates table created');

    // Insert default email template
    await pool.query(`
      INSERT INTO message_templates (type, name, subject, body)
      VALUES ('email', 'Receipt', 'Your PharmSecure Receipt', 'Dear Customer, Please find your receipt attached.')
      ON CONFLICT DO NOTHING;
    `);

    console.log('✅ All Phase 5G-Extended tables created successfully!');
  } catch (error) {
    console.error('❌ Migration failed:', error.message);
  }
};

module.exports = { createTables };
