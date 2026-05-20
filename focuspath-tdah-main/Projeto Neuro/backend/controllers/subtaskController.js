const db = require('../config/db');

// Listar subtasks de uma tarefa
exports.getSubtasks = (req, res) => {
  const { taskId } = req.params;
  db.query('SELECT * FROM subtasks WHERE taskId=?', [taskId], (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
};

// Criar subtask
exports.createSubtask = (req, res) => {
  const { taskId } = req.params;
  const { titulo } = req.body;
  db.query(
    'INSERT INTO subtasks (titulo, concluida, taskId) VALUES (?, 0, ?)',
    [titulo, taskId],
    (err, result) => {
      if (err) return res.status(500).json(err);
      res.status(201).json({ message: 'Etapa criada', id: result.insertId });
    }
  );
};

// Marcar como concluída/pendente
exports.toggleSubtask = (req, res) => {
  const { id } = req.params;
  const { concluida } = req.body;
  db.query(
    'UPDATE subtasks SET concluida=? WHERE id=?',
    [concluida, id],
    (err) => {
      if (err) return res.status(500).json(err);
      res.json({ message: 'Atualizada' });
    }
  );
};

// Deletar subtask
exports.deleteSubtask = (req, res) => {
  const { id } = req.params;
  db.query('DELETE FROM subtasks WHERE id=?', [id], (err) => {
    if (err) return res.status(500).json(err);
    res.json({ message: 'Removida' });
  });
};