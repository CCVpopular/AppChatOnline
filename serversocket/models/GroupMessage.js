const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const GroupMessageSchema = new Schema({
  groupId: { type: Schema.Types.ObjectId, ref: 'Group', required: true },
  sender: { type: Schema.Types.ObjectId, ref: 'User', required: true },
  message: { type: String, required: true },
  timestamp: { type: Date, default: Date.now },
});

module.exports = mongoose.model('GroupMessage', GroupMessageSchema);
