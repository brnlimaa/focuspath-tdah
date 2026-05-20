import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_task_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map tarefa;

  const TaskDetailScreen({super.key, required this.tarefa});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  List subtasks = [];
  final novaEtapaController = TextEditingController();

  final Map<String, Color> coresPrioridade = {
    'alta': Colors.red,
    'media': Colors.orange,
    'baixa': Colors.green,
  };

  Future carregarSubtasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final id = widget.tarefa['id'];

      final response = await http.get(
        Uri.parse('http://10.0.2.2:4000/tasks/$id/subtasks'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          subtasks = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future criarSubtask() async {
    if (novaEtapaController.text.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final id = widget.tarefa['id'];

      final response = await http.post(
        Uri.parse('http://10.0.2.2:4000/tasks/$id/subtasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'titulo': novaEtapaController.text}),
      );

      if (response.statusCode == 201) {
        novaEtapaController.clear();
        carregarSubtasks();
      }
    } catch (e) {
      print(e);
    }
  }

  Future toggleSubtask(int id, bool concluida) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final taskId = widget.tarefa['id'];

      await http.put(
        Uri.parse('http://10.0.2.2:4000/tasks/$taskId/subtasks/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'concluida': concluida ? 1 : 0}),
      );

      carregarSubtasks();
    } catch (e) {
      print(e);
    }
  }

  Future deletarSubtask(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final taskId = widget.tarefa['id'];

      await http.delete(
        Uri.parse('http://10.0.2.2:4000/tasks/$taskId/subtasks/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      carregarSubtasks();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    carregarSubtasks();
  }

  @override
  Widget build(BuildContext context) {
    final prioridade = widget.tarefa['prioridade'] ?? 'media';
    final cor = coresPrioridade[prioridade] ?? Colors.orange;
    final concluidas = subtasks.where((s) => s['concluida'] == 1).length;
    final total = subtasks.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da tarefa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditTaskScreen(tarefa: widget.tarefa),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card da tarefa
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: cor, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.tarefa['titulo'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: cor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            prioridade[0].toUpperCase() +
                                prioridade.substring(1),
                            style: TextStyle(
                                color: cor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(widget.tarefa['descricao']),
                    if (total > 0) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: concluidas / total,
                        color: cor,
                        backgroundColor: cor.withOpacity(0.2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$concluidas de $total etapas concluídas',
                        style:
                        const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Mini-etapas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Campo para nova etapa
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: novaEtapaController,
                    decoration: const InputDecoration(
                      hintText: 'Nova etapa...',
                      border: OutlineInputBorder(),
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (_) => criarSubtask(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: criarSubtask,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Lista de subtasks
            Expanded(
              child: subtasks.isEmpty
                  ? const Center(
                child: Text(
                  'Nenhuma etapa ainda.\nAdicione etapas para dividir a tarefa!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: subtasks.length,
                itemBuilder: (context, index) {
                  final sub = subtasks[index];
                  final concluida = sub['concluida'] == 1;

                  return ListTile(
                    leading: Checkbox(
                      value: concluida,
                      activeColor: cor,
                      onChanged: (val) =>
                          toggleSubtask(sub['id'], val ?? false),
                    ),
                    title: Text(
                      sub['titulo'],
                      style: TextStyle(
                        decoration: concluida
                            ? TextDecoration.lineThrough
                            : null,
                        color: concluida ? Colors.grey : null,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      onPressed: () => deletarSubtask(sub['id']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}