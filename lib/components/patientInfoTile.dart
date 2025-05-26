import 'package:flutter/material.dart';
import 'package:morflutter/design/constants.dart';

class PatientInfoTile extends StatelessWidget {
  final String parameter;
  final String value;
  const PatientInfoTile(
      {super.key, required this.value, required this.parameter});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(parameter,
            style:
                TextStyle(fontWeight: FontWeight.bold, color: darkPeriwinkle)),
        SizedBox(
          height: 5,
        ),
        Container(
            width: 350,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: lilyPurple)),
            padding: EdgeInsets.all(10),
            child: Text(value)),
      ],
    );
  }
}
