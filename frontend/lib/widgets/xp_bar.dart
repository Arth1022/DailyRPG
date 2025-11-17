import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Renomeei para XpBar para seguir a convenção no HunterHeader
class XpBar extends StatelessWidget {
  final int currentXp;
  final int nextLevelXp;

  const XpBar({super.key, required this.currentXp, required this.nextLevelXp});

  @override
  Widget build(BuildContext context) {
    // Cores do tema XP
    const xpBackgroundColor = Color.fromARGB(255, 30, 30, 30); // Fundo Escuro
    const xpFillColor = Color.fromARGB(255, 85, 166, 82); // Verde Pixelado
    const barHeight = 28.0;

    double percentage = 0.0;
    if (nextLevelXp > 0) {
      percentage = currentXp / nextLevelXp;
    }
    percentage = percentage.clamp(0.0, 1.0);

    return Container(
      // Removido width, pois o widget Expanded no HunterHeader já define a largura
      height: barHeight,
      // Usando BoxShape.rectangle com borda definida para o visual pixelado
      decoration: BoxDecoration(
        color: xpBackgroundColor,
        border: Border.all(color: Colors.white54, width: 2),
        // Removido BorderRadius para manter os cantos retos (Beveled) ou use BeveledRectangleBorder no Container pai se necessário
      ),

      // O Padding aqui é opcional, mas ajuda a dar espaço para a borda
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Barra de preenchimento (Fill)
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: const BoxDecoration(
                color: xpFillColor,
                // Adiciona uma sombra interna leve para profundidade (opcional)
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

          // Texto de status do XP
          Center(
            child: Text(
              "$currentXp / $nextLevelXp XP",
              // Aplicando a fonte Press Start 2P
              style: GoogleFonts.pressStart2p(
                color: Colors.white,
                fontSize: 9.0, // Tamanho reduzido para caber
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
