const db = require('../config/db');

// Listar tarefas
exports.getTasks = (req,res)=>{

db.query(
'SELECT * FROM tasks',

(err,result)=>{

if(err){

return res.status(500).json(err);

}

res.json(result);

});

};


// Criar tarefa
exports.createTask=(req,res)=>{

const {

titulo,
descricao,
prioridade,
categoria,
dataLimite,
userId

}=req.body;

db.query(

`INSERT INTO tasks
(titulo,descricao,prioridade,categoria,dataLimite,userId)

VALUES(?,?,?,?,?,?)`,

[
titulo,
descricao,
prioridade,
categoria,
dataLimite,
userId
],

(err,result)=>{

if(err){

return res.status(500).json(err);

}

res.json({

message:"Tarefa criada"

});

}

);

};


// Atualizar
exports.updateTask=(req,res)=>{

const {id}=req.params;

const {

titulo,
descricao,
prioridade

}=req.body;

db.query(

`UPDATE tasks
SET titulo=?,descricao=?,prioridade=?

WHERE id=?`,

[
titulo,
descricao,
prioridade,
id
],

(err)=>{

if(err){

return res.status(500).json(err);

}

res.json({

message:"Atualizada"

});

}

);

};


// Deletar
exports.deleteTask=(req,res)=>{

const {id}=req.params;

db.query(

'DELETE FROM tasks WHERE id=?',

[id],

(err)=>{

if(err){

return res.status(500).json(err);

}

res.json({

message:"Removida"

});

}

);

};