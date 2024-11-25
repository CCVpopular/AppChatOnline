const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const mongoose = require('mongoose');
const authRoutes = require('./routes/authRoutes');
const friendRoutes = require('./routes/friendRoutes');
const messageRoutes = require('./routes/messageRoutes');
const Message = require('./models/Message');
const userRoutes = require('./routes/userRoutes');
const roomRoutes = require('./routes/roomRoutes');

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

app.locals.io = io;

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
app.use('/api/rooms', roomRoutes);

io.on('connection', (socket) => {
  console.log('New client connected');

  socket.on('joinRoom', ({ userId, friendId }) => {
    const roomName = [userId, friendId].sort().join('_');
    console.log(`Current rooms for socket ${socket.id}:`, Array.from(socket.rooms));
    socket.join(roomName);
    console.log(`${userId} joined room ${roomName}`);

    // const room = io.sockets.adapter.rooms.get(roomName);
    // console.log(`Users in room ${roomName}:`, room ? room.size : 0);
  });

  socket.on('sendMessage', async (data) => {
    try {
      const { sender, receiver, message } = data;

      if (!sender || !receiver || !message) {
        console.error('Invalid message data:', data);
        return;
      }
  

      const roomName = [sender, receiver].sort().join('_');

      const newMessage = new Message({ sender, receiver, message });
      await newMessage.save();
  

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



  socket.on('joinRoom', ({ userId, friendId }) => {
    const roomName = [userId, friendId].sort().join('_');
    socket.join(roomName);
    console.log(`${userId} joined room ${roomName}`);
  });


  socket.on('offer', (data) => {
    const { roomName, sdp } = data;
    console.log(`Offer received for room ${roomName}`);
    socket.to(roomName).emit('offer', { sdp, from: socket.id });
  });

  socket.on('answer', (data) => {
    const { roomName, sdp } = data;
    console.log(`Answer received for room ${roomName}`);
    socket.to(roomName).emit('answer', { sdp, from: socket.id });
  });

  socket.on('candidate', (data) => {
    const { roomName, candidate } = data;
    console.log(`ICE candidate received for room ${roomName}`);
    socket.to(roomName).emit('candidate', { candidate, from: socket.id });
  });

  socket.on('leaveRoom', ({ userId, friendId }) => {
    const roomName = [userId, friendId].sort().join('_');
    socket.leave(roomName);
    console.log(`${userId} left room ${roomName}`);
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected');
  });
// });

// io.on('connection', (socket) => {
//   console.log('New client connected');

//   // Xử lý khi người dùng tham gia phòng
//   socket.on('joinRoom', ({ userId, friendId }) => {
//     const roomName = [userId, friendId].sort().join('_');
//     socket.join(roomName);
//     console.log(`${userId} joined room ${roomName}`);
//   });

//   // Signaling: Xử lý 'offer' từ peer A
//   socket.on('offer', (data) => {
//     const { roomName, sdp } = data;
//     console.log(`Offer received for room ${roomName}`);
//     // Gửi SDP của offer tới các peer khác trong phòng
//     socket.to(roomName).emit('offer', { sdp, from: socket.id });
//   });

//   // Signaling: Xử lý 'answer' từ peer B
//   socket.on('answer', (data) => {
//     const { roomName, sdp } = data;
//     console.log(`Answer received for room ${roomName}`);
//     // Gửi SDP của answer tới peer đã gửi offer
//     socket.to(roomName).emit('answer', { sdp, from: socket.id });
//   });

//   // Signaling: Xử lý ICE Candidate
//   socket.on('candidate', (data) => {
//     const { roomName, candidate } = data;
//     console.log(`ICE candidate received for room ${roomName}`);
//     // Gửi ICE Candidate tới các peer khác trong phòng
//     socket.to(roomName).emit('candidate', { candidate, from: socket.id });
//   });

//   // Người dùng rời phòng
//   socket.on('leaveRoom', ({ userId, friendId }) => {
//     const roomName = [userId, friendId].sort().join('_');
//     socket.leave(roomName);
//     console.log(`${userId} left room ${roomName}`);
//   });

//   // Ngắt kết nối
//   socket.on('disconnect', () => {
//     console.log('Client disconnected');
//   });
// });





// Start server
server.listen(3000, '0.0.0.0', () => console.log('Server is running on :3000'));
