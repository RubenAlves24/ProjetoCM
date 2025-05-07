import 'package:flutter/material.dart';

class SellsPage extends StatefulWidget {
  const SellsPage({super.key});

  @override
  State<SellsPage> createState() => _SellsPageState();
}

class _SellsPageState extends State<SellsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Vendas"));
  }
}
