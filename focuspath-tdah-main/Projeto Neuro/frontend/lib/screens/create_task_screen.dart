import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();
  String prioridade = 'media';
  DateTime? dataLimite;
  bool carregando = false;

  final Map<String, Color> coresPrioridade = {
    'alta': Colors.red,
    'media': Colors.orange,
    'baixa': Colors.green,
  };

  Future selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (data != null) setState(() => dataLimite = data);
  }

  String? _formatarData(DateTime? data) {
    if (data == null) return null;
    return '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')} 00:00:00';
  }

  Future criarTarefa() async {
    if (tituloController.text.isEmpty || descricaoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    setState(() => carregando = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('http://10.0.0.152:4000/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'titulo': tituloController.text,
          'descricao': descricaoController.text,
          'prioridade': prioridade,
          'dataLimite': _formatarData(dataLimite),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }

    setState(() => carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Nova tarefa')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Prioridade', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: ['alta', 'media', 'baixa'].map((p) {
                final selecionado = prioridade == p;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => prioridade = p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selecionado
                              ? coresPrioridade[p]
                              : coresPrioridade[p]!.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: selecionado
                              ? Border.all(color: coresPrioridade[p]!, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            p[0].toUpperCase() + p.substring(1),
                            style: TextStyle(
                              color: selecionado
                                  ? Colors.white
                                  : coresPrioridade[p],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Data limite', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: selecionarData,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      dataLimite == null
                          ? 'Selecionar data'
                          : '${dataLimite!.day.toString().padLeft(2, '0')}/${dataLimite!.month.toString().padLeft(2, '0')}/${dataLimite!.year}',
                      style: TextStyle(
                        color: dataLimite == null ? Colors.grey : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: carregando ? null : criarTarefa,
                child: carregando
                    ? const CircularProgressIndicator()
                    : const Text('Salvar'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}