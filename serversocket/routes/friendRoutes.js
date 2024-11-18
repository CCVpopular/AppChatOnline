const express = require('express');
const Friendship = require('../models/Friendship');

const router = express.Router();

// Kết bạn
router.post('/add-friend', async (req, res) => {
  const { requesterId, receiverId } = req.body;
  const friendship = new Friendship({ requester: requesterId, receiver: receiverId });
  try {
    await friendship.save();
    res.status(201).send('Friend request sent');
  } catch (err) {
    res.status(400).send({ error: err.message });
  }
});

// Danh sách bạn bè
router.get('/friends/:userId', async (req, res) => {
  const userId = req.params.userId;
  try {
    const friends = await Friendship.find({
      $or: [{ requester: userId }, { receiver: userId }],
      status: 'accepted',
    }).populate('requester receiver');
    res.send(friends);
  } catch (err) {
    res.status(500).send({ error: 'Failed to fetch friends' });
  }
});

// Xác nhận yêu cầu kết bạn
router.post('/accept-friend', async (req, res) => {
  const { friendshipId } = req.body;
  try {
    const friendship = await Friendship.findByIdAndUpdate(friendshipId, { status: 'accepted' });
    if (friendship) {
      res.send('Friend request accepted');
    } else {
      res.status(400).send({ error: 'Friendship not found' });
    }
  } catch (err) {
    res.status(500).send({ error: 'Failed to accept friend request' });
  }
});

module.exports = router;
