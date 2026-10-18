import 'package:flutter/material.dart';
import 'opcoes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: 
          Column(
            children: [
              Container(
                color: Colors.grey,
                height: 250,
                width: 250,
                margin: const EdgeInsets.fromLTRB(0, 250, 0, 20)),
                Text("Bem-vindo ao Aprender+")
            ],
          ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
      children: [
         SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             IconButton(
           iconSize: 40,
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
           Navigator.pop(context);
                    },
                  ),
                  Opcoes()
            ]
              ),
            )
          ],
        ),
      ),
    );
  }
}