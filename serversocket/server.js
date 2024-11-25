const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const mongoose = require('mongoose');
const authRoutes = require('./routes/authRoutes');
const friendRoutes = require('./routes/friendRoutes');
const messageRoutes = require('./routes/messageRoutes');
const Message = require('./models/Message');
const userRoutes = require('./routes/userRoutes');
const groupsRoutes = require('./routes/groupRoutes')

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

// Kết nối MongoDB
mongoose.connect('mongodb://localhost:27017/chatApp', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});
mongoose.connection.on('connected', () => console.log('MongoDB connected'));
mongoose.connection.on('error', (err) => console.error('MongoDB connection error:', err));

app.set('socketio', io);

// Middleware
app.use(express.json());

// Routes


app.use('/api/auth', authRoutes);
app.use('/api/friends', friendRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/users', userRoutes);
app.use('/api/groups', groupsRoutes);

io.on('connection', (socket) => {
  console.log('New client connected');

  socket.on('joinRoom', ({ userId, friendId }) => {
    // Tạo tên phòng duy nhất cho hai người dùng
    const roomName = [userId, friendId].sort().join('_');
    // socket.leaveAll(); 
    console.log(`Current rooms for socket ${socket.id}:`, Array.from(socket.rooms));
    socket.join(roomName);
    console.log(`${userId} joined room ${roomName}`);

    // const room = io.sockets.adapter.rooms.get(roomName);
    // console.log(`Users in room ${roomName}:`, room ? room.size : 0);
  });

  socket.on('sendMessage', async (data) => {
    try {
      const { sender, receiver, message } = data;
  
      // Kiểm tra dữ liệu đầu vào
      if (!sender || !receiver || !message) {
        console.error('Invalid message data:', data);
        return;
      }
  
      // Tạo tên phòng
      const roomName = [sender, receiver].sort().join('_');
  
      // Lưu tin nhắn vào cơ sở dữ liệu
      const newMessage = new Message({ sender, receiver, message });
      await newMessage.save();
  
      // Gửi tin nhắn tới phòng
      io.to(roomName).emit('receiveMessage', data);
    } catch (err) {
      console.error('Error handling sendMessage:', err);
    }
  });  

  socket.on('leaveRoom', ({ userId, friendId }) => {
    const roomName = [userId, friendId].sort().join('_');
    socket.leave(roomName);
    console.log(`${userId} left room ${roomName}`);
  });


  // Join a group
  socket.on('joinGroup', ({ groupId, userId }) => {
    socket.join(groupId);
    console.log(`${userId} joined group: ${groupId}`);
    socket.to(groupId).emit('userJoined', `${userId} has joined the group.`);
  });

  // Send a message to a group
  socket.on('sendGroupMessage', async ({ groupId, sender, message }) => {
    try {
      // Emit the message to the group
      io.to(groupId).emit('receiveGroupMessage', { sender, message });
    } catch (err) {
      console.error('Error sending group message:', err);
    }
  });
  

  socket.on('disconnect', () => {
    console.log('Client disconnected');
  });

  
});

// Start server
server.listen(3000, '0.0.0.0', () => console.log('Server is running on :3000'));
