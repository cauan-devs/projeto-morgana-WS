import 'package:flutter/material.dart';


class Quizmybrain extends StatefulWidget {
  const Quizmybrain({super.key});

  @override
  State<Quizmybrain> createState() => _QuizmybrainState();
}

class _QuizmybrainState extends State<Quizmybrain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(onPressed: () {
        Navigator.pop(context);
      }, child: Text("sair do QuizMyBrain?"))
    );
  }
}