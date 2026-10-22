import 'package:flutter/material.dart';

class Memocheck extends StatefulWidget {
  const Memocheck({super.key});

  @override
  State<Memocheck> createState() => _MemocheckState();
}

class _MemocheckState extends State<Memocheck> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(onPressed: () {
        Navigator.pop(context);
      }, child: Text("sair do memoCheck?")),
    );
  }
}