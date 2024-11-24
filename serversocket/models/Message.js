const mongoose = require('mongoose');

const MessageSchema = new mongoose.Schema({
  sender: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  receiver: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  message: { type: String, required: true, trim: true },
  timestamp: { type: String, default: () => new Date().toISOString() }, // Lưu timestamp dưới dạng chuỗi ISO 8601
  status: { type: String, enum: ['sent', 'delivered', 'read'], default: 'sent' },
});

module.exports = mongoose.model('Message', MessageSchema);
