const db = require('../config/db');
const jwt = require('jsonwebtoken');

function getUserId(req) {
  const auth = req.headers['authorization'];
  if (!auth) return null;
  const token = auth.split(' ')[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    return decoded.id;
  } catch {
    return null;
  }
}

// Listar tarefas do usuário
exports.getTasks = (req, res) => {
  const userId = getUserId(req);
  if (!userId) return res.status(401).json({ message: 'Não autorizado' });

  db.query('SELECT * FROM tasks WHERE userId=?', [userId], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
};

// Criar tarefa
exports.createTask = (req, res) => {
  const userId = getUserId(req);
  if (!userId) return res.status(401).json({ message: 'Não autorizado' });

  const { titulo, descricao, prioridade, categoria, dataLimite } = req.body;
  db.query(
    'INSERT INTO tasks (titulo,descricao,prioridade,categoria,dataLimite,userId) VALUES(?,?,?,?,?,?)',
    [titulo, descricao, prioridade || 'media', categoria, dataLimite, userId],
    (err, result) => {
      if (err) return res.status(500).json(err);
      res.status(201).json({ message: 'Tarefa criada', id: result.insertId });
    }
  );
};

// Atualizar
exports.updateTask = (req, res) => {
  const userId = getUserId(req);
  if (!userId) return res.status(401).json({ message: 'Não autorizado' });

  const { id } = req.params;
  const { titulo, descricao, prioridade } = req.body;
  db.query(
    'UPDATE tasks SET titulo=?,descricao=?,prioridade=? WHERE id=? AND userId=?',
    [titulo, descricao, prioridade || 'media', id, userId],
    (err) => {
      if (err) return res.status(500).json(err);
      res.json({ message: 'Atualizada' });
    }
  );
};

// Deletar
exports.deleteTask = (req, res) => {
  const userId = getUserId(req);
  if (!userId) return res.status(401).json({ message: 'Não autorizado' });

  const { id } = req.params;
  db.query('DELETE FROM tasks WHERE id=? AND userId=?', [id, userId], (err) => {
    if (err) return res.status(500).json(err);
    res.json({ message: 'Removida' });
  });
};