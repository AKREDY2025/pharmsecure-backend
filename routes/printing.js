const express = require('express');
const router = express.Router();
const pool = require('../db');
const { authenticateToken } = require('../middleware/auth');
const QRCode = require('qrcode');
const PDFDocument = require('pdfkit');
const bwipjs = require('bwip-js');
const nodemailer = require('nodemailer');

// Email transporter
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.GMAIL_USER,
    pass: process.env.GMAIL_APP_PASSWORD
  }
});

// Helper function to get receipt data
async function getReceiptData(orderId) {
  const result = await pool.query(
    'SELECT * FROM pending_orders WHERE id = $1',
    [orderId]
  );
  if (result.rows.length === 0) return null;
  return result.rows[0];
}

// GET /api/printing/receipt/:order_id
router.get('/receipt/:order_id', authenticateToken, async (req, res) => {
  try {
    const receipt = await getReceiptData(req.params.order_id);
    if (!receipt) return res.status(404).json({ error: 'Order not found' });
    res.json(receipt);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/printing/qr/:order_id
router.get('/qr/:order_id', authenticateToken, async (req, res) => {
  try {
    const receipt = await getReceiptData(req.params.order_id);
    if (!receipt) return res.status(404).json({ error: 'Order not found' });
    const qrData = await QRCode.toDataURL(`ORDER-${receipt.id}-${receipt.order_number}`);
    res.json({ qr_code: qrData });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/printing/pdf/:order_id
router.get('/pdf/:order_id', authenticateToken, async (req, res) => {
  try {
    const receipt = await getReceiptData(req.params.order_id);
    if (!receipt) return res.status(404).json({ error: 'Order not found' });
    const doc = new PDFDocument({ margin: 40 });
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="Receipt-${receipt.id}.pdf"`);
    doc.pipe(res);
    doc.fontSize(14).font('Helvetica-Bold').text('PharmSecure Receipt', { align: 'center' });
    doc.fontSize(10).font('Helvetica').text(`Order #${receipt.id}`, { align: 'center' });
    doc.text(`Date: ${new Date(receipt.created_at).toLocaleString()}`, { align: 'center' });
    doc.moveTo(40, doc.y).lineTo(555, doc.y).stroke();
    doc.moveDown();
    doc.fontSize(9).text(`Customer: ${receipt.customer_name || 'Walk-in'}`, { width: 500 });
    doc.text(`Amount: GHS ${parseFloat(receipt.total_amount).toFixed(2)}`, { width: 500 });
    doc.moveDown();
    doc.text(`Status: ${receipt.status.toUpperCase()}`, { width: 500 });
    doc.moveTo(40, doc.y).lineTo(555, doc.y).stroke();
    doc.moveDown();
    doc.text('Thank you for your purchase!', { align: 'center' });
    doc.end();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/printing/receipts
router.get('/receipts', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM pending_orders LIMIT 20 ORDER BY id DESC');
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// GET /api/printing/stats
router.get('/stats', authenticateToken, async (req, res) => {
  try {
    const totalResult = await pool.query('SELECT COUNT(*) as count FROM pending_orders');
    const todayResult = await pool.query("SELECT COUNT(*) as count FROM pending_orders WHERE DATE(created_at) = CURRENT_DATE");
    const weekResult = await pool.query("SELECT COUNT(*) as count FROM pending_orders WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'");
    res.json({
      total_receipts: parseInt(totalResult.rows[0].count),
      today_receipts: parseInt(todayResult.rows[0].count),
      week_receipts: parseInt(weekResult.rows[0].count)
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// POST /api/printing/email/:order_id - Send receipt via email
router.post('/email/:order_id', authenticateToken, async (req, res) => {
  try {
    const { email, message_type } = req.body;
    if (!email) {
      return res.status(400).json({ error: 'Email address required' });
    }
    const receipt = await getReceiptData(req.params.order_id);
    if (!receipt) return res.status(404).json({ error: 'Order not found' });
    
    // Create email content
    const subject = `PharmSecure Receipt #${receipt.id}`;
    let htmlContent = `
      <html>
        <body>
          <h2>PharmSecure Receipt</h2>
          <p><strong>Order ID:</strong> ${receipt.id}</p>
          <p><strong>Customer:</strong> ${receipt.customer_name || 'Walk-in'}</p>
          <p><strong>Amount:</strong> GHS ${parseFloat(receipt.total_amount).toFixed(2)}</p>
          <p><strong>Status:</strong> ${receipt.status.toUpperCase()}</p>
          <p><strong>Date:</strong> ${new Date(receipt.created_at).toLocaleString()}</p>
          <p>Thank you for your purchase!</p>
        </body>
      </html>
    `;
    
    // Send email
    await transporter.sendMail({
      from: process.env.GMAIL_USER,
      to: email,
      subject: subject,
      html: htmlContent
    });
    
    // Log sent email to database
    await pool.query(
      'INSERT INTO sent_emails (order_id, recipient_email, status) VALUES ($1, $2, $3)',
      [receipt.id, email, 'sent']
    );
    res.json({ success: true, message: `Receipt email sent to ${email}` });
  } catch (error) {
    res.status(500).json({ error: 'Failed to send receipt email', details: error.message });
  }
});

// POST /api/printing/sms/:order_id - Send receipt via SMS
router.post('/sms/:order_id', authenticateToken, async (req, res) => {
  try {
    const { phone_number, message_type } = req.body;
    if (!phone_number) {
      return res.status(400).json({ error: 'Phone number required' });
    }
    const receipt = await getReceiptData(req.params.order_id);
    if (!receipt) return res.status(404).json({ error: 'Order not found' });
    
    // Log SMS to database
    await pool.query(
      'INSERT INTO sent_sms (order_id, phone_number, status) VALUES ($1, $2, $3)',
      [receipt.id, phone_number, 'sent']
    );
    res.json({ success: true, message: `SMS would be sent to ${phone_number}` });
  } catch (error) {
    res.status(500).json({ error: 'Failed to send SMS', details: error.message });
  }
});

// GET /api/printing/barcode/:product_id
router.get('/barcode/:product_id', authenticateToken, async (req, res) => {
  try {
    const { product_id } = req.params;
    const { qty = 5 } = req.query;
    const quantity = Math.min(parseInt(qty), 100);
    
    const productResult = await pool.query('SELECT id, name, unit_price FROM products WHERE id = $1', [product_id]);
    if (productResult.rows.length === 0) return res.status(404).json({ error: 'Product not found' });
    
    const product = productResult.rows[0];
    const doc = new PDFDocument({ margin: 20, size: 'A4' });
    
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename="Barcodes-${product.name}-${Date.now()}.pdf"`);
    doc.pipe(res);
    
    let labelCount = 0;
    for (let i = 1; i <= quantity; i++) {
      if (labelCount > 0 && labelCount % 3 === 0) {
        doc.addPage();
      }
      
      const yPos = 50 + (labelCount % 3) * 250;
      doc.rect(40, yPos, 500, 200).stroke();
      
      // Generate barcode
      try {
        const png = await bwipjs.toBuffer({
          bcid: 'code128',
          text: `${product.id}`,
          scale: 2,
          height: 8,
          includetext: true,
          textxalign: 'center'
        });
        
        doc.image(png, 50, yPos + 10, { width: 200, height: 100 });
      } catch (err) {
        doc.text('*' + product.id, 50, yPos + 50);
      }
      
      doc.fontSize(12).font('Helvetica-Bold').text(product.name, 270, yPos + 30, { width: 250 });
      doc.fontSize(11).font('Helvetica').text(`GHS ${parseFloat(product.unit_price).toFixed(2)}`, 270, yPos + 60, { width: 250 });
      doc.fontSize(9).text(`Label ${i} of ${quantity}`, 270, yPos + 160, { width: 250 });
      
      labelCount++;
    }
    
    doc.end();
  } catch (error) {
    res.status(500).json({ error: 'Failed to generate barcodes', details: error.message });
  }
});

module.exports = router;
