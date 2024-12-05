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
const KEY_FILE_PATH = path.join(__dirname, '../setup_googdrive.json');
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
      //name: 'upload',
      name: req.file.filename, // Tên file trên Google Drive
      parents: ['1uoKXq4MXKEpEMT3_Fwdtttm84AIpq-h0'],
    };
    const media = {
      mimeType: req.file.mimetype,
      body: fs.createReadStream(req.file.path),
    };
    const filePath = req.file.path;
    if (!fs.existsSync(filePath)) {
      console.error('File not found at path:', filePath);
      return res.status(400).send({ error: 'File does not exist' });
    }
    if (!fs.existsSync(req.file.path)) {
      return res.status(400).send({ error: 'File does not exist at the given path' });
    }
    const driveResponse = await drive.files.create({
      resource: fileMetadata,
      media,
      fields: 'id',
    }).catch(error => {
      console.error('Error uploading file to Google Drive:', error.response ? error.response.data : error);
      throw new Error('Failed to upload file to Google Drive');
    });

    console.log('Google Drive upload response:', driveResponse.data);

    // Xóa file tạm sau khi upload
    //fs.unlinkSync(req.file.path);
    try {
      await fs.promises.unlink(req.file.path);
    } catch (err) {
      console.error('Error deleting temporary file:', err.message);
    }

    const fileStream = fs.createReadStream(req.file.path);
    fileStream.on('close', () => {
      console.log('File stream closed successfully');
    });

    // Lấy link file từ Google Drive
    const fileId = driveResponse.data.id;
    const fileUrl = `https://drive.google.com/uc?id=${fileId}&export=download`;

    await drive.permissions.create({
      fileId: fileId,
      requestBody: {
        role: 'reader',
        type: 'anyone',
      },
    });

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
    res.status(500).send({ error: 'Server error', details: error.message }); // Log error message
  }

});

module.exports = router;
