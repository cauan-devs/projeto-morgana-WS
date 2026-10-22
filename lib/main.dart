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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 200,
                width: 700,
                child: Image.asset('assets/images/aprender.png',
                ),
              ),
              Text("Bem vindo ao Aprender+")
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
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
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