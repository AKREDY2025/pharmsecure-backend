const logAuditTrail = async (pool, userId, action, tableName, recordId, before, after) => {
  try {
    await pool.query(
      `INSERT INTO audit_log (user_id, action, table_name, record_id, before_data, after_data)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [userId, action, tableName, recordId, JSON.stringify(before), JSON.stringify(after)]
    );
  } catch (error) {
    console.error('Error logging audit trail:', error);
  }
};

module.exports = { logAuditTrail };
