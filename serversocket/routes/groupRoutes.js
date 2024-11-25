const express = require('express');
const router = express.Router();
const Group = require('../models/Group');

// Create a new group
router.post('/create', async (req, res) => {
  const { groupName, creator, members } = req.body;

  try {
    const group = new Group({
      groupName,
      creator,
      members: [creator, ...members],
    });

    await group.save();
    res.status(201).json(group);
  } catch (err) {
    res.status(500).json({ error: 'Error creating group', details: err });
  }
});

module.exports = router;
