import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:morflutter/design/constants.dart';

/*
void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.transparent,
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
*/

/*
  Hacemos uso de showGeneralDialogue(), un widget que nos deja renderizar cualquier widget como un 
  objeto animado, con duración determinada.
    - Sintaxis: (_, __, ___) 
      1. context
      2. primary animation
      3 secondary animation
*/
void showSuccessAnimation(BuildContext context) {
  showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => Center(
            child: Container(
              width: 300,
              height: 350,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset('lib/design/renders/star_celebration.json'),
                  Text(
                    '¡Lo lograste!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    'Eres más fuerte de lo que crees...',
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                      decoration: TextDecoration.none,
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ));
  // cierre automático de la animación
  Future.delayed(Duration(milliseconds: 2500), () {
    Navigator.of(context).pop();
  });
}
