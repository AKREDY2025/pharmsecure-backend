const twilio = require('twilio');

const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const twilioPhoneNumber = process.env.TWILIO_PHONE_NUMBER;

const client = twilio(accountSid, authToken);

// Test the connection
if (accountSid && authToken && twilioPhoneNumber) {
  console.log('✅ SMS service (Twilio) configured');
} else {
  console.log('⚠️  SMS service not configured - missing credentials');
}

module.exports = { client, twilioPhoneNumber };
