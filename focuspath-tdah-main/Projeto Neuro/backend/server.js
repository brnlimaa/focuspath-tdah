require('dotenv').config();
const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const taskRoutes = require('./routes/taskRoutes');
const subtaskRoutes = require('./routes/subtaskRoutes');

const app = express();
app.use(cors());
app.use(express.json());

require('./config/db');

app.use('/auth', authRoutes);
app.use('/tasks', taskRoutes);
app.use('/tasks/:taskId/subtasks', subtaskRoutes);

app.listen(process.env.PORT, () => {
  console.log("Servidor rodando");
});