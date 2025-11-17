import 'package:dailyrpg/screens/inventory_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/hunter_user.dart';
import 'health_bar.dart';
import 'xp_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HunterHeader extends StatelessWidget {
  final HunterUser hunter;

  const HunterHeader({super.key, required this.hunter});

  @override
  Widget build(BuildContext context) {
    // Definindo as cores e estilos do tema
    const pixelPrimaryColor = Color.fromARGB(255, 77, 167, 209); // Azul Ciano
    const darkCardColor = Color(0xff222222); // Fundo do Card
    const goldColor = Colors.amber;
    const hpColor = Color(0xFFE53935); // Vermelho da Vida
    const xpColor = Color.fromARGB(255, 85, 166, 82); // Verde do XP

    final pixelTitleStyle = GoogleFonts.pressStart2p(
      fontSize: 14,
      color: Colors.white,
    );
    final pixelLevelStyle = GoogleFonts.pressStart2p(
      fontSize: 12,
      color: xpColor,
    );
    final pixelGoldStyle = GoogleFonts.pressStart2p(
      fontSize: 12,
      color: goldColor,
    );

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: darkCardColor,
        // Borda Pixelada: Chanfrada (Beveled) para o efeito de canto cortado
        shape: BoxShape.rectangle,
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGEM DO CAÇADOR (HERÓI)
          Container(
            width: 135,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              image: const DecorationImage(
                image: AssetImage('assets/images/hero.gif'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(width: 15.0),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NOME DO CAÇADOR
                Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.userShield,
                      color: pixelPrimaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        hunter.hunterName,
                        style: pixelTitleStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Divisor Estilizado
                const Divider(height: 15, color: Colors.white12),

                // BARRA DE VIDA (HP)
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.heartPulse,
                      color: hpColor,
                      size: 20.0,
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: HealthBar(
                        currentHp: hunter.currentHp,
                        maxHp: hunter.maxHp,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),

                // BARRA DE EXPERIÊNCIA (XP)
                Row(
                  children: [
                    Icon(FontAwesomeIcons.diamond, color: xpColor, size: 20.0),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: XpBar(
                        currentXp: hunter.currentXp,
                        nextLevelXp: hunter.nextLevelXp,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),

                // STATS (NÍVEL E GOLD) E BOTÃO INVENTÁRIO
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      // NÍVEL
                      Icon(FontAwesomeIcons.book, color: xpColor, size: 20.0),
                      const SizedBox(width: 8.0),
                      Text('${hunter.level}', style: pixelLevelStyle),

                      const SizedBox(width: 15.0),

                      // GOLD
                      Icon(FontAwesomeIcons.coins, color: goldColor, size: 18),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          ' ${hunter.currentCoins}G',
                          style: pixelGoldStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // BOTÃO INVENTÁRIO
                      Container(
                        decoration: const BoxDecoration(
                          color: darkCardColor,

                          shape: BoxShape.rectangle,
                        ),
                        child: IconButton(
                          icon: const Icon(FontAwesomeIcons.layerGroup),
                          iconSize: 20.0,
                          color: Colors.white,
                          padding: const EdgeInsets.all(6),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InventoryScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
