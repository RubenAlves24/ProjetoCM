import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {
  final String text;

  const CustomChip({required this.text, super.key});

  // Color dateChipColor(String dateText) {
  //   if (dateText == 'Hoje') {
  //     return Colors.green.shade300;
  //   } else if (dateText == 'Ontem') {
  //     return Colors.blue.shade300;
  //   } else {
  //     return Colors.grey.shade400;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 7, bottom: 7),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            color: Colors.grey.shade400,
          ),
          child: Padding(padding: const EdgeInsets.all(5.0), child: Text(text)),
        ),
      ),
    );
  }
}
