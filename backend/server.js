
const express = require('express');
const morgan = require('morgan');
const http = require('http'); 
const { Server } = require('socket.io');
const { DBconnect } = require('./Config/db_config');
const routerapi = require('./routerapi');
const path = require('path');
const colors = require('colors');
const cors = require('cors');
const fileUpload = require('express-fileupload');
const session = require('express-session');
require('dotenv').config();

// ✅ Create Express app
const app = express();
app.use(morgan('dev')); // Logging middleware for development
const server = http.createServer(app); // 🛜 HTTP server created for socket.io
const io = new Server(server, {
  cors: {
    origin: "*", // Frontend allowed origin
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
    allowedHeaders: ["Content-Type", "Authorization"]
  }
});

// ✅ Make socket.io accessible inside routes/controllers
app.set('socketio', io);

// ✅ Database connect
DBconnect();

// ✅ Safe temp dir path for file uploads
const tempDir = path.join(__dirname, 'tmp');
app.use(express.urlencoded({ extended: true }));
app.use(express.json());


// ✅ Middlewares
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
  allowedHeaders: ["Content-Type", "Authorization"]
}));

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

app.use(fileUpload({
  useTempFiles: true,
  tempFileDir: tempDir,
  limits: { fileSize: 50 * 1024 * 1024 }, // 50MB
  safeFileNames: true,
  preserveExtension: 4,
  abortOnLimit: true,
  limitHandler: function (req, res, next) {
    res.status(400).send('File size limit exceeded');
  }
}));

app.use(express.static(path.join(__dirname, 'public')));
app.use(express.static(path.join(__dirname, 'upload')));

// ✅ Session middleware
app.use(session({
  secret: 'your_secret_key', // Change in production
  resave: false,
  saveUninitialized: true,
  cookie: { maxAge: 86400000 }
}));

// ✅ Default route
app.get('/', (req, res) => {
  res.send('Backend Live 🚀');
});

app.get('/api/test', (req, res) => {
  res.send('API Working 🚀');
});

// ✅ API router
// app.use(routerapi);
app.use("/api", routerapi);

// ✅ Upload folder static
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ✅ Socket.io basic connection check (optional)
io.on('connection', (socket) => {
  console.log(`New client connected: ${socket.id}`);

  socket.on('disconnect', () => {
    console.log(`Client disconnected: ${socket.id}`);
  });
});

// ✅ Server Start (Use server.listen not app.listen!)
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

