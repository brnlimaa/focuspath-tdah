const db = require('../config/db');

// Listar tarefas do usuário
exports.getTasks = (req, res) => {
  db.query('SELECT * FROM tasks WHERE userId=?', [req.userId], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
};

// Criar tarefa
exports.createTask = (req, res) => {
  const { titulo, descricao, prioridade, categoria, dataLimite } = req.body;
  db.query(
    'INSERT INTO tasks (titulo,descricao,prioridade,categoria,dataLimite,userId) VALUES(?,?,?,?,?,?)',
    [titulo, descricao, prioridade || 'media', categoria, dataLimite, req.userId],
    (err, result) => {
      if (err) return res.status(500).json(err);
      res.status(201).json({ message: 'Tarefa criada', id: result.insertId });
    }
  );
};

// Atualizar
exports.updateTask = (req, res) => {
  const { id } = req.params;
  const { titulo, descricao, prioridade, dataLimite } = req.body;
  db.query(
    'UPDATE tasks SET titulo=?,descricao=?,prioridade=?,dataLimite=? WHERE id=? AND userId=?',
    [titulo, descricao, prioridade || 'media', dataLimite, id, req.userId],
    (err) => {
      if (err) return res.status(500).json(err);
      res.json({ message: 'Atualizada' });
    }
  );
};

// Deletar
exports.deleteTask = (req, res) => {
  const { id } = req.params;
  db.query('DELETE FROM tasks WHERE id=? AND userId=?', [id, req.userId], (err) => {
    if (err) return res.status(500).json(err);
    res.json({ message: 'Removida' });
  });
};