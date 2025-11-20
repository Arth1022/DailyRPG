import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Renomeado para HealthBar para seguir a convenção no HunterHeader
class HealthBar extends StatelessWidget {
  final int currentHp;
  final int maxHp;

  const HealthBar({super.key, required this.currentHp, required this.maxHp});

  @override
  Widget build(BuildContext context) {
    // Cores do tema HP
    const hpBackgroundColor = Color.fromARGB(255, 30, 30, 30); // Fundo Escuro
    const hpFillColor = Color(0xFFE53935); // Vermelho da Vida
    const barHeight = 28.0;

    double percentage = 0.0;
    if (maxHp > 0) {
      percentage = currentHp / maxHp;
    }
    percentage = percentage.clamp(0.0, 1.0);

    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: hpBackgroundColor,
        border: Border.all(color: Colors.white54, width: 2),
      ),

      child: Stack(
        fit: StackFit.expand,
        children: [
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: const BoxDecoration(
                color: hpFillColor,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(100, 0, 0, 0),
                    offset: Offset(1.0, 0.0),
                    blurRadius: 3.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
            ),
          ),

          // Texto de status da Vida
          Center(
            child: Text(
              "$currentHp / $maxHp HP",
              style: GoogleFonts.pressStart2p(
                color: Colors.white,
                fontSize: 9.0, 
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 4.0,
                    offset: Offset(1.5, 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
