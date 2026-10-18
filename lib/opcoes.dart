import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Opcoes extends StatefulWidget {
  const Opcoes({super.key});

  @override
  State<Opcoes> createState() => _OpcoesState();
}

class _OpcoesState extends State<Opcoes> {
  @override
  Widget build(BuildContext context) {
    return  Padding(
               padding: const EdgeInsets.only(top: 250.0),
              child: Column(
                children: [
                  ListTile(
                    onTap: () => Navigator.pop(context),
                    title: Text(
                      "Home",
                      textAlign: TextAlign.justify,
                      style: GoogleFonts.breeSerif(
                        fontWeight: FontWeight.w900,
                        color: Colors.purple),
                    ),
                  ),
                Divider(
                  color: Colors.purple,
                  thickness: 2,
                  indent: 15,
                  endIndent: 15,
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  title: Text("QuizMyBrain", textAlign: TextAlign.justify, style: GoogleFonts.breeSerif(
                    fontWeight: FontWeight.w900,
                    color: Colors.purple),
                  ),
                  ),
                Divider( color: Colors.purple,
                  thickness: 2,
                  indent: 15,
                  endIndent: 15,
                ),
                 ListTile(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  title: Text("GeniusPLay", textAlign: TextAlign.justify, style: GoogleFonts.breeSerif(
                    fontWeight: FontWeight.w900,
                    color: Colors.purple),
                  ),
                ),
                Divider(color: Colors.purple,
                  thickness: 2,
                  indent: 15,
                  endIndent: 15,
                ),
                 ListTile(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  title: Text("MemoCheck", textAlign: TextAlign.justify, style: GoogleFonts.breeSerif(
                    fontWeight: FontWeight.w900,
                    color: Colors.purple),
                  ),
                ),
                Divider( color: Colors.purple,
                  thickness: 2,
                  indent: 15,
                  endIndent: 15,
                ),
                 ListTile(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  title: Text("Sair", textAlign: TextAlign.justify, style: GoogleFonts.breeSerif(
                    fontWeight: FontWeight.w900,
                    color: Colors.purple),
                  ),
                ),
                Divider( color: Colors.purple,
                  thickness: 2,
                  indent: 15,
                  endIndent: 15,
                ),
                ],
              ),
    );
  }
}
