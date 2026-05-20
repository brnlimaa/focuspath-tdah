import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  int minutosFoco = 25;
  int minutosPausaCurta = 5;
  int minutosPausaLonga = 15;

  late int tempoRestante;
  bool rodando = false;
  bool emFoco = true;
  int ciclos = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    tempoRestante = minutosFoco * 60;
  }

  String get fase {
    if (emFoco) return 'Foco';
    if (ciclos % 4 == 0) return 'Pausa Longa';
    return 'Pausa Curta';
  }

  Color get cor {
    if (emFoco) return Colors.deepPurple;
    if (ciclos % 4 == 0) return Colors.teal;
    return Colors.green;
  }

  String get tempoFormatado {
    final min = (tempoRestante ~/ 60).toString().padLeft(2, '0');
    final seg = (tempoRestante % 60).toString().padLeft(2, '0');
    return '$min:$seg';
  }

  int get totalAtual {
    if (emFoco) return minutosFoco * 60;
    if (ciclos % 4 == 0) return minutosPausaLonga * 60;
    return minutosPausaCurta * 60;
  }

  double get progresso => 1 - (tempoRestante / totalAtual);

  void iniciar() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (tempoRestante > 0) {
        setState(() => tempoRestante--);
      } else {
        timer?.cancel();

        final eraFoco = emFoco; // salva estado ANTES de trocar

        setState(() {
          rodando = false;
          if (emFoco) {
            ciclos++;
            emFoco = false;
            tempoRestante = ciclos % 4 == 0
                ? minutosPausaLonga * 60
                : minutosPausaCurta * 60;
          } else {
            emFoco = true;
            tempoRestante = minutosFoco * 60;
          }
        });

        _mostrarAlerta(eraFoco);
      }
    });
    setState(() => rodando = true);
  }

  void pausar() {
    timer?.cancel();
    setState(() => rodando = false);
  }

  void resetar() {
    timer?.cancel();
    setState(() {
      rodando = false;
      emFoco = true;
      ciclos = 0;
      tempoRestante = minutosFoco * 60;
    });
  }

  void _mostrarAlerta(bool eraFoco) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(eraFoco ? '☕ Hora da pausa!' : '🎯 Hora de focar!'),
        content: Text(eraFoco
            ? 'Ciclo concluído! Descanse um pouco.'
            : 'Pausa encerrada. Vamos focar!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              iniciar();
            },
            child: const Text('Iniciar'),
          ),
        ],
      ),
    );
  }

  void _abrirConfiguracoes() {
    if (rodando) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pause o timer antes de configurar')),
      );
      return;
    }

    int tempFoco = minutosFoco;
    int tempPausaCurta = minutosPausaCurta;
    int tempPausaLonga = minutosPausaLonga;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('⚙️ Configurar tempos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sliderConfig(
                label: 'Foco',
                valor: tempFoco.toDouble(),
                min: 1,
                max: 60,
                cor: Colors.deepPurple,
                onChanged: (v) => setDialogState(() => tempFoco = v.round()),
              ),
              const SizedBox(height: 16),
              _sliderConfig(
                label: 'Pausa curta',
                valor: tempPausaCurta.toDouble(),
                min: 1,
                max: 30,
                cor: Colors.green,
                onChanged: (v) =>
                    setDialogState(() => tempPausaCurta = v.round()),
              ),
              const SizedBox(height: 16),
              _sliderConfig(
                label: 'Pausa longa',
                valor: tempPausaLonga.toDouble(),
                min: 1,
                max: 60,
                cor: Colors.teal,
                onChanged: (v) =>
                    setDialogState(() => tempPausaLonga = v.round()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  minutosFoco = tempFoco;
                  minutosPausaCurta = tempPausaCurta;
                  minutosPausaLonga = tempPausaLonga;
                  tempoRestante = minutosFoco * 60;
                  emFoco = true;
                  ciclos = 0;
                });
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sliderConfig({
    required String label,
    required double valor,
    required double min,
    required double max,
    required Color cor,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '${valor.round()} min',
              style: TextStyle(color: cor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: valor,
          min: min,
          max: max,
          divisions: (max - min).round(),
          activeColor: cor,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configurar tempos',
            onPressed: _abrirConfiguracoes,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: cor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                fase,
                style: TextStyle(
                  fontSize: 18,
                  color: cor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: progresso,
                    strokeWidth: 12,
                    backgroundColor: cor.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(cor),
                  ),
                ),
                Text(
                  tempoFormatado,
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: cor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ciclos concluídos: $ciclos',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Foco: ${minutosFoco}min | Pausa: ${minutosPausaCurta}min | Longa: ${minutosPausaLonga}min',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: rodando ? pausar : iniciar,
                  icon: Icon(rodando ? Icons.pause : Icons.play_arrow),
                  label: Text(rodando ? 'Pausar' : 'Iniciar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: resetar,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Resetar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cor,
                    side: BorderSide(color: cor),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}