
# 📄 Firestore Snapshots & Parseo – Notas de Biniza

## 🧠 ¿Qué es un snapshot?

Un **snapshot** en Firestore representa el resultado de una consulta (query) o la lectura directa de un documento.

- `DocumentSnapshot`: una lectura de un solo documento.
- `QuerySnapshot`: el resultado de una consulta que regresa múltiples documentos.

---

## 🔁 Uso típico – QuerySnapshot

```dart
final snapshot = await FirebaseFirestore.instance
  .collection('patients')
  .doc(userId)
  .collection('emg_sessions')
  .get();
```

- Aquí `snapshot.docs` es una lista de `QueryDocumentSnapshot`.
- Cada `doc.data()` es un `Map<String, dynamic>` que contiene los datos del documento.

---

## 📥 Cómo parsear múltiples documentos

```dart
final readings = snapshot.docs.map((doc) {
  final data = doc.data(); // Mapa con todos los campos del doc
  final datapoints = data['datapoints'] ?? []; // campo anidado

  return EmgSession.fromJson({
    ...data,
    'datapoints': datapoints,
  });
}).toList();
```

> 👆 `...data` combina todos los campos directamente del documento con los campos adicionales o corregidos.

---

## 🧯 Errores comunes y cómo evitarlos

| Error | Causa común | Solución |
|------|--------------|----------|
| `Null is not a subtype of type 'String'` | Campo esperado como `String` viene nulo o está mal tipeado | 1. Validar existencia del campo antes de usarlo. 2. Declarar como `String?` en el modelo |
| `The getter 'exists' isn't defined for type 'QuerySnapshot'` | `exists` solo está definido en `DocumentSnapshot`, no en `QuerySnapshot` | Usar `snapshot.docs.isEmpty` en lugar de `snapshot.exists` |

---

## ✅ Buenas prácticas

- Siempre valida que los campos requeridos estén presentes.
- Usa `?? []` cuando accedas a listas que podrían no estar inicializadas.
- Declara tus campos como `String?`, `int?`, etc., si pueden venir nulos.
- Si usas `.orderBy(...)`, asegúrate que ese campo exista en **todos** los documentos.
