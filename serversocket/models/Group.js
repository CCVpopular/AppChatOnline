const mongoose = require('mongoose');

const groupSchema = new mongoose.Schema({
  groupName: { type: String, required: true },
  creator: { type: String, required: true }, // ID of the group creator
  members: { type: [String], required: true }, // Array of member IDs
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Group', groupSchema);
