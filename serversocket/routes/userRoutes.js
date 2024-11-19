const express = require('express');
const User = require('../models/User');

const router = express.Router();

// Tìm kiếm người dùng theo tên
router.get('/search/:username', async (req, res) => {
  const { username } = req.params;
  try {
    // Tìm kiếm người dùng có tên chứa đoạn text (không phân biệt hoa thường)
    const users = await User.find({
      username: { $regex: username, $options: 'i' }, // $regex cho phép tìm kiếm gần đúng
    }).select('_id username'); // Chỉ lấy _id và username

    res.send(users);
  } catch (err) {
    console.error('Error searching users:', err);
    res.status(500).send({ error: 'Failed to search users' });
  }
});

module.exports = router;
