import 'package:flutter/material.dart';

class Geniusplay extends StatefulWidget {
  const Geniusplay({super.key});

  @override
  State<Geniusplay> createState() => _GeniusplayState();
}

class _GeniusplayState extends State<Geniusplay> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(onPressed: () {
        Navigator.pop(context);
      }, child: const Text("sair do Genius?")),
    );
  }
}