const express = require('express');
const { google } = require('googleapis');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
const Message = require('../models/Message');

const router = express.Router();

// Cấu hình multer (chỉ để lưu tạm file trước khi upload lên Google Drive)
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // Lưu tạm file
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});
const upload = multer({ storage });

// Cấu hình Google Drive API
const SCOPES = ['https://www.googleapis.com/auth/drive.file'];
const KEY_FILE_PATH = path.join(__dirname, '../path-to-your-service-account.json');
const auth = new google.auth.GoogleAuth({
  keyFile: KEY_FILE_PATH,
  scopes: SCOPES,
});
const drive = google.drive({ version: 'v3', auth });

router.post('/upload', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).send({ error: 'No file uploaded' });
    }

    const { sender, receiver } = req.body;

    // Upload file lên Google Drive
    const fileMetadata = {
      name: req.file.filename, // Tên file trên Google Drive
      parents: ['your-google-drive-folder-id'], // ID thư mục trên Google Drive
    };
    const media = {
      mimeType: req.file.mimetype,
      body: fs.createReadStream(req.file.path),
    };
    const driveResponse = await drive.files.create({
      resource: fileMetadata,
      media,
      fields: 'id',
    });

    // Xóa file tạm sau khi upload
    fs.unlinkSync(req.file.path);

    // Lấy link file từ Google Drive
    const fileId = driveResponse.data.id;
    const fileUrl = `https://drive.google.com/uc?id=${fileId}&export=download`;

    // Lưu thông tin tin nhắn vào database
    const newMessage = new Message({
      sender,
      receiver,
      message: 'File received',
      fileUrl,
      messageType: 'file',
    });

    await newMessage.save();

    // Gửi thông điệp qua WebSocket
    const roomName = [sender, receiver].sort().join('_');
    const io = req.app.get('socketio');
    io.to(roomName).emit('receiveMessage', {
      sender,
      receiver,
      message: 'File received',
      fileUrl,
      messageType: 'file',
    });

    res.status(200).send({ message: 'File uploaded successfully', fileUrl });
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).send({ error: 'Server error' });
  }
});

module.exports = router;
