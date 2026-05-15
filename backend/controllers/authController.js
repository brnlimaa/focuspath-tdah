const db = require('../config/db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// Cadastro
exports.register = async (req, res) => {

    const { nome, email, senha } = req.body;

    try {

        const hash = await bcrypt.hash(senha, 10);

        db.query(
            'INSERT INTO users(nome,email,senha) VALUES(?,?,?)',
            [nome, email, hash],
            (err, result) => {

                if (err) {
                    return res.status(500).json({
                        erro: err.message
                    });
                }

                res.status(201).json({
                    message: 'Usuário criado'
                });
            }
        );

    } catch {

        res.status(500).json({
            message:'Erro no cadastro'
        });

    }

};

// Login
exports.login = (req,res)=>{

const {email,senha}=req.body;

db.query(
'SELECT * FROM users WHERE email=?',

[email],

async(err,result)=>{

if(err)
return res.status(500).json(err);

if(result.length===0){

return res.status(404).json({
message:'Usuário não encontrado'
});

}

const user=result[0];

const senhaCorreta=
await bcrypt.compare(
senha,
user.senha
);

if(!senhaCorreta){

return res.status(401).json({
message:'Senha incorreta'
});

}

const token=
jwt.sign(

{id:user.id},

process.env.JWT_SECRET,

{
expiresIn:'1d'
}

);

res.json({

token,
nome:user.nome

});

}

);

};