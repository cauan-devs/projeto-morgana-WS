import 'package:flutter/material.dart';
import 'package:ws_morgana/perguntasquiz.dart';

class Quizmybrain extends StatefulWidget {
  const Quizmybrain({super.key});

  @override
  State<Quizmybrain> createState() => _QuizmybrainState();
}

class _QuizmybrainState extends State<Quizmybrain> {
  bool quizIniciado = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: quizIniciado
          ? const Perguntasquiz()
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 36,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Preparado para o quiz??',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                quizIniciado = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                            ),
                            child: const Text('Sim'),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Colors.black),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                            ),
                            child: const Text('Não'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ),
    );
  }
}