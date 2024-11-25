const express = require('express');
const mongoose = require('mongoose');

const router = express.Router();

// Schema cho Room
const roomSchema = new mongoose.Schema({
    name: { type: String, required: true },
    createdAt: { type: Date, default: Date.now },
});
const Room = mongoose.model('Room', roomSchema);

// API để tạo phòng
router.post('/create-room', async (req, res) => {
    const { name } = req.body;

    if (!name) {
        return res.status(400).send({ error: 'Room name is required' });
    }

    try {
        const newRoom = new Room({ name });
        await newRoom.save();
        res.status(201).send(newRoom);
    } catch (err) {
        res.status(500).send({ error: 'Failed to create room' });
    }
});

// API để lấy danh sách các phòng
router.get('/rooms', async (req, res) => {
    try {
        const rooms = await Room.find().sort({ createdAt: -1 });
        res.status(200).send(rooms);
    } catch (err) {
        res.status(500).send({ error: 'Failed to fetch rooms' });
    }
});

module.exports = router;
