import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ws_morgana/geniusplay.dart';
import 'package:ws_morgana/memocheck.dart';
import 'package:ws_morgana/quizmybrain.dart';

class Opcoes extends StatefulWidget {
  const Opcoes({super.key});

  @override
  State<Opcoes> createState() => _OpcoesState();
}

class _OpcoesState extends State<Opcoes> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(),
      child: Column(
        children: [
          Icon(Icons.account_circle, color: Color(0xFF3C00A7), size: 200),

          ListTile(
            onTap: () => Navigator.pop(context),
            title: Text(
              "Home",
              textAlign: TextAlign.justify,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900,
                color: Color(0xFF3C00A7),
              ),
            ),
          ),
          Divider(
            color: Color(0xFF3C00A7),
            thickness: 2,
            indent: 15,
            endIndent: 15,
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Quizmybrain()),
              );
            },
            title: Text(
              "QuizMyBrain",
              textAlign: TextAlign.justify,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900,
                color: Color(0xFF3C00A7),
              ),
            ),
          ),
          Divider(
            color: Color(0xFF3C00A7),
            thickness: 2,
            indent: 15,
            endIndent: 15,
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Geniusplay()),
              );
            },
            title: Text(
              "GeniusPLay",
              textAlign: TextAlign.justify,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900,
                color: Color(0xFF3C00A7),
              ),
            ),
          ),
          Divider(
            color: Color(0xFF3C00A7),
            thickness: 2,
            indent: 15,
            endIndent: 15,
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Memocheck()),
              );
            },
            title: Text(
              "MemoCheck",
              textAlign: TextAlign.justify,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900,
                color: Color(0xFF3C00A7),
              ),
            ),
          ),
          Divider(
            color: Color(0xFF3C00A7),
            thickness: 2,
            indent: 15,
            endIndent: 15,
          ),
          ListTile(
            onTap: () {
              SystemNavigator.pop();
            },
            title: Text(
              "Sair",
              textAlign: TextAlign.justify,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900,
                color: Color(0xFF3C00A7),
              ),
            ),
          ),
          Divider(
            color: Color(0xFF3C00A7),
            thickness: 2,
            indent: 15,
            endIndent: 15,
          ),
        ],
      ),
    );
  }
}
