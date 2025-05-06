import 'package:flutter/material.dart';

class TimeStampReport extends StatelessWidget {
  final List<IdealContraction> contractions;

  const TimeStampReport({super.key, required this.contractions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte de Contracciones Ideales')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: contractions.length,
          itemBuilder: (context, index) {
            final contraction = contractions[index];
            return ListTile(
              leading: Icon(Icons.bolt, color: Colors.deepPurple),
              title: Text(
                'Contracción ideal #${index + 1}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                // formato lindo (chat)
                'Inicio: ${contraction.startTime.hour}:${contraction.startTime.minute}:${contraction.startTime.second}\n'
                'Duración: ${contraction.duration.inMilliseconds} ms',
              ),
            );
          },
        ),
      ),
    );
  }
}

/* Clase exclusiva para almacenar tiempo de contracción ideal */
class IdealContraction {
  final DateTime startTime;
  final Duration duration;

  IdealContraction({required this.startTime, required this.duration});
}
