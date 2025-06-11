# 🚀 Future vs. Stream vs. SimpleState

📅 Fecha: 2025-06-11  
📁 Contexto: Hack de Morfo – Histórico de sesiones con Firestore

---

## 🧠 ¿Qué aprendí?

Aprendí a diferenciar cuándo usar FutureBuilder, StreamBuilder o lógica personalizada para acceder a Firestore según el tipo de consulta.

StreamBuilder:
Obtener datos continuamente, con actualización automática.
Ideal para: 
- chats
- sensores en vivo

FutureBuilder:
Obtener datos una sola vez, contenido estático/histórico.
Ideal para:
- Perfil
- Historiales

initState + setState:
Obtener datos con actualización automática, con un análisis/manipulación adicional, como: fltrar, agrupar, ordenar. 
Ideal para:
- Dashboards con análisis hecho en el front.



---

## 🔧 Ejemplos de código

### StreamBuilder

```dart
StreamBuilder<List<Datapoint>>(
  stream: streamTelemetryData('sessionId'),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    final data = snapshot.data!;
    return ListView.builder(...);
  },
)
```

### FutureBuilder

```dart
class ReadingHistoryScreen extends StatelessWidget {
  final String sessionId;

  ReadingHistoryScreen({required this.sessionId});

  Future<List<Datapoint>> fetchDatapoints() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('emg_sessions')
        .doc(sessionId)
        .get();

    final raw = snapshot.data()?['readings'] as List<dynamic>? ?? [];
    return raw.map((e) => Datapoint.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Datapoint>>(
      future: fetchDatapoints(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        final datapoints = snapshot.data!;
        return ListView.builder(
          itemCount: datapoints.length,
          itemBuilder: (context, index) {
            return Text('${datapoints[index].value}');
          },
        );
      },
    );
  }
}
```

### init + setState
```dart
class _ReadingHistoryScreenState extends State<ReadingHistoryScreen> {
  List<Datapoint> datapoints = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchDatapoints();
  }

  Future<void> fetchDatapoints() async {
    setState(() => isLoading = true);
    final snapshot = await FirebaseFirestore.instance
        .collection('emg_sessions')
        .doc(widget.sessionId)
        .get();

    final raw = snapshot.data()?['readings'] as List<dynamic>? ?? [];
    setState(() {
      datapoints = raw.map((e) => Datapoint.fromJson(e)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return CircularProgressIndicator();
    return ListView.builder(
      itemCount: datapoints.length,
      itemBuilder: (context, index) {
        return Text('${datapoints[index].value}');
      },
    );
  }
}
```




