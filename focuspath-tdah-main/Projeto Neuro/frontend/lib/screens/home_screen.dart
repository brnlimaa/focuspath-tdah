import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../app_settings.dart';
import 'create_task_screen.dart';
import 'task_detail_screen.dart';
import 'pomodoro_screen.dart';
import 'login_screen.dart';

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

  final List<String> diasSemana = [
    'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'
  ];

  Future carregarTarefas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://10.0.0.152:4000/tasks'),
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
        Uri.parse('http://10.0.0.152:4000/tasks/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) carregarTarefas();
    } catch (e) {
      print(e);
    }
  }

  Future logout() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  String _labelDia(DateTime data) {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final amanha = hoje.add(const Duration(days: 1));
    final dia = DateTime(data.year, data.month, data.day);

    if (dia == hoje) return 'Hoje';
    if (dia == amanha) return 'Amanhã';

    final nomeDia = diasSemana[data.weekday - 1];
    return '$nomeDia, ${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';
  }

  Map<String, List> _agruparPorDia() {
    final Map<String, List> grupos = {};
    final semData = <dynamic>[];

    for (final tarefa in tarefas) {
      if (tarefa['dataLimite'] == null || tarefa['dataLimite'] == '') {
        semData.add(tarefa);
      } else {
        final data = DateTime.tryParse(tarefa['dataLimite']);
        if (data == null) {
          semData.add(tarefa);
        } else {
          final label = _labelDia(data);
          grupos[label] = grupos[label] ?? [];
          grupos[label]!.add(tarefa);
        }
      }
    }

    final ordenado = Map.fromEntries(
      grupos.entries.toList()
        ..sort((a, b) {
          if (a.key == 'Hoje') return -1;
          if (b.key == 'Hoje') return 1;
          if (a.key == 'Amanhã') return -1;
          if (b.key == 'Amanhã') return 1;
          return a.key.compareTo(b.key);
        }),
    );

    if (semData.isNotEmpty) {
      ordenado['Sem data'] = semData;
    }

    return ordenado;
  }

  Widget _buildCard(dynamic tarefa, AppSettings settings) {
    final prioridade = tarefa['prioridade'] ?? 'media';
    final cor = coresPrioridade[prioridade] ?? Colors.orange;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.black12, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                color: cor,
              ),
              Expanded(
                child: ListTile(
                  title: Text(
                    tarefa['titulo'],
                    style: TextStyle(
                      fontSize: settings.textoGrande ? 20 : 16,
                      fontFamily: 'sans-serif',
                    ),
                  ),
                  subtitle: Text(
                    tarefa['descricao'],
                    style: TextStyle(
                      fontSize: settings.textoGrande ? 16 : 13,
                      fontFamily: 'sans-serif',
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          prioridade[0].toUpperCase() +
                              prioridade.substring(1),
                          style: TextStyle(
                            color: cor,
                            fontSize: settings.textoGrande ? 14 : 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Excluir tarefa'),
                              content: const Text(
                                  'Tem certeza que deseja excluir esta tarefa?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: const Text('Excluir',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                          if (confirmar == true) deletarTarefa(tarefa['id']);
                        },
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.of(context);
    final grupos = _agruparPorDia();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusPath'),
        actions: [
          IconButton(
            icon: Icon(
              settings.textoGrande
                  ? Icons.text_decrease
                  : Icons.text_increase,
            ),
            tooltip:
            settings.textoGrande ? 'Diminuir texto' : 'Aumentar texto',
            onPressed: settings.toggleTextoGrande,
          ),
          IconButton(
            icon: Icon(
              settings.altoContraste
                  ? Icons.contrast
                  : Icons.contrast_outlined,
            ),
            tooltip: settings.altoContraste
                ? 'Desativar alto contraste'
                : 'Alto contraste',
            onPressed: settings.toggleAltoContraste,
          ),
          IconButton(
            icon: const Icon(Icons.timer),
            tooltip: 'Pomodoro',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PomodoroScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: logout,
          ),
        ],
      ),
      body: tarefas.isEmpty
          ? const Center(child: Text('Nenhuma tarefa'))
          : ListView(
        children: grupos.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  children: [
                    Icon(
                      entry.key == 'Hoje'
                          ? Icons.today
                          : entry.key == 'Amanhã'
                          ? Icons.event
                          : entry.key == 'Sem data'
                          ? Icons.calendar_today_outlined
                          : Icons.date_range,
                      size: 18,
                      color: entry.key == 'Hoje'
                          ? const Color(0xFF7B9FD4)
                          : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: settings.textoGrande ? 18 : 15,
                        fontWeight: FontWeight.bold,
                        color: entry.key == 'Hoje'
                            ? const Color(0xFF7B9FD4)
                            : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${entry.value.length}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              ...entry.value
                  .map((tarefa) => _buildCard(tarefa, settings))
                  .toList(),
            ],
          );
        }).toList(),
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