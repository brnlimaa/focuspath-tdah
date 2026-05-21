# focusPath 🧠

Aplicativo mobile feito em Flutter para ajudar pessoas com TDAH a organizar as tarefas do dia a dia. Projeto desenvolvido como MVP acadêmico.

---

## O que o app faz?

- Cadastro e login com autenticação JWT
- Criar, editar e excluir tarefas
- Definir prioridade (Alta, Média, Baixa) e data limite
- Dividir tarefas em mini-etapas com checkbox de progresso
- Timer Pomodoro integrado para ajudar na concentração
- Opções de acessibilidade: aumentar texto e alto contraste
- Tarefas agrupadas por dia (Hoje, Amanhã, etc.)

---

## Tecnologias usadas

**Frontend**
- Flutter + Dart
- `http` para consumir a API
- `shared_preferences` para salvar o token JWT

**Backend**
- Node.js + Express
- MySQL
- bcrypt (hash de senha)
- jsonwebtoken (autenticação)

---

## Telas

| Tela | Descrição |
|------|-----------|
| Login | Entrada com email e senha |
| Cadastro | Criação de conta com validação de senha forte |
| Home | Lista de tarefas agrupadas por data |
| Criar Tarefa | Formulário com título, descrição, prioridade e data limite |
| Editar Tarefa | Edição dos dados de uma tarefa existente |
| Detalhes da Tarefa | Mini-etapas com barra de progresso |
| Pomodoro | Timer com fases de foco e pausa configuráveis |

---

## Rotas da API

**Autenticação**
```
POST /auth/register   → cadastro
POST /auth/login      → login, retorna o token JWT
```

**Tarefas** *(requer token)*
```
GET    /tasks         → listar tarefas
POST   /tasks         → criar tarefa
PUT    /tasks/:id     → editar tarefa
DELETE /tasks/:id     → excluir tarefa
```

**Mini-etapas** *(requer token)*
```
GET    /tasks/:taskId/subtasks        → listar etapas
POST   /tasks/:taskId/subtasks        → criar etapa
PUT    /tasks/:taskId/subtasks/:id    → marcar como concluída
DELETE /tasks/:taskId/subtasks/:id    → excluir etapa
```

---

## Banco de dados

Três tabelas: `users`, `tasks` e `subtasks`.

```sql
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100),
  email VARCHAR(100) UNIQUE,
  senha VARCHAR(255)
);

CREATE TABLE tasks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  titulo VARCHAR(100),
  descricao TEXT,
  prioridade ENUM('alta', 'media', 'baixa') DEFAULT 'media',
  categoria VARCHAR(50),
  dataLimite DATETIME,
  userId INT,
  FOREIGN KEY (userId) REFERENCES users(id)
);

CREATE TABLE subtasks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  titulo VARCHAR(100),
  concluida TINYINT(1) DEFAULT 0,
  taskId INT,
  FOREIGN KEY (taskId) REFERENCES tasks(id)
);
```

---

## Como rodar

**Backend**
```bash
cd backend
npm install
node server.js
```

**Frontend**
```bash
cd frontend
flutter pub get
flutter run
```

> O IP da API está fixo como `10.0.0.152:4000` nos arquivos do app. Troque pelo IP da sua máquina na rede local.

---

## Variáveis de ambiente

Crie um `.env` dentro da pasta `backend/`:

```env
DB_HOST=localhost
DB_USER=seu_usuario
DB_PASSWORD=sua_senha
DB_NAME=nome_do_banco
JWT_SECRET=sua_chave_secreta
PORT=4000
```
