import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'create_task_screen.dart';
import 'task_detail_screen.dart';
import 'pomodoro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List tarefas = [];

  final Map<String, Color> coresPrioridade = {
    'alta': Colors.red,
    'media': Colors.orange,
    'baixa': Colors.green,
  };

  Future carregarTarefas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://10.0.2.2:4000/tasks'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          tarefas = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future deletarTarefa(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.delete(
        Uri.parse('http://10.0.2.2:4000/tasks/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) carregarTarefas();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusPath'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            tooltip: 'Pomodoro',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PomodoroScreen()),
            ),
          ),
        ],
      ),
      body: tarefas.isEmpty
          ? const Center(child: Text('Nenhuma tarefa'))
          : ListView.builder(
        itemCount: tarefas.length,
        itemBuilder: (context, index) {
          final tarefa = tarefas[index];
          final prioridade = tarefa['prioridade'] ?? 'media';
          final cor = coresPrioridade[prioridade] ?? Colors.orange;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: cor, width: 2),
            ),
            child: ListTile(
              leading: Container(
                width: 12,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: cor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              title: Text(tarefa['titulo']),
              subtitle: Text(tarefa['descricao']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: cor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      prioridade[0].toUpperCase() + prioridade.substring(1),
                      style: TextStyle(
                          color: cor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deletarTarefa(tarefa['id']),
                  ),
                ],
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskDetailScreen(tarefa: tarefa),
                  ),
                );
                carregarTarefas();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
          );
          carregarTarefas();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}