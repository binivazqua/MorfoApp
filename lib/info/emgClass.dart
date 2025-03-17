class EMGData {
  final String timestamp;
  final int valor;
  final String muscle;
  final int secs;

  EMGData(
      {required this.timestamp,
      required this.valor,
      required this.muscle,
      required this.secs});

  /*
  Usamos factory para constructores en los que buscas retournear una instancia pre existente.
   Transforma la data raw a nuestra medida
  */
  factory EMGData.fromMap(String time, Map<String, dynamic> data) {
    return EMGData(
      timestamp: time,
      valor: int.tryParse(data['Valor'].toString()) ?? 0, // -> valor default
      muscle: data['Musculo'] ?? 'Desconocido',
      secs: int.tryParse(data['Tiempo'].toString()) ?? 0,
    );
  }

  /* Overrideamos método para hacer más debugueable el asuntacho*/
  @override
  String toString() {
    return 'EMGData(timestamp: $timestamp, value: $valor, muscleGroup: $muscle, seconds: $secs)';
  }
}
