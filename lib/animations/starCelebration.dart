import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("¡Sesión completada!"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset('lib/design/renders/star_celebration.json',
              width: 150, height: 150),
          const SizedBox(height: 10),
          const Text("¡Gran trabajo! Tu esfuerzo es increíble 🎉"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cerrar"),
        )
      ],
    ),
  );
}
