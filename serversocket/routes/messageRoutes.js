const express = require('express');
const Message = require('../models/Message');
const multer = require('multer');
const path = require('path');
const router = express.Router();




router.get('/messages/:sender/:receiver', async (req, res) => {
  const { sender, receiver } = req.params;
  try {
    if (!sender || !receiver) {
      return res.status(400).send({ error: 'Sender and receiver are required' });
    }

    const messages = await Message.find({
      $or: [
        { sender, receiver },
        { sender: receiver, receiver: sender },
      ],
    }).sort({ timestamp: 1 }); 

    res.status(200).send(messages);
  } catch (err) {
    console.error('Failed to fetch messages:', err);
    res.status(500).send({ error: 'Failed to fetch messages' });
  }
});


const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); 
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname)); 
  },
});

const upload = multer({ storage });


router.post('/upload', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).send('No file uploaded');
    }

    const { sender, receiver } = req.body;
    const fileUrl = `/uploads/${req.file.filename}`; 

 
    const newMessage = new Message({
      sender,
      receiver,
      message: 'File received', 
      fileUrl,
      messageType: 'file',
    });

    await newMessage.save();

  
    const roomName = [sender, receiver].sort().join('_');
    io.to(roomName).emit('receiveMessage', {
      sender,
      receiver,
      message: 'File received',
      fileUrl,
      messageType: 'file',
    });

    res.status(200).send({ fileUrl });
  } catch (error) {
    console.error(error);
    res.status(500).send('Server error');
  }
});

module.exports = router;
