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

  // --- Paleta "Iron & Stone" ---
  static const Color _stoneDark = Color(0xFF1C1C1C); // Fundo Pedra
  static const Color _ironGrey = Color(0xFF455A64); // Borda Metálica
  static const Color _gold = Color(0xFFFFD700);
  static const Color _bloodRed = Color(0xFFD32F2F);
  static const Color _xpGreen = Color(0xFF388E3C);
  static const Color _panelBg = Color(0xFF121212); // Fundo dos slots

  TextStyle get _pixelTitle =>
      GoogleFonts.pressStart2p(fontSize: 12, color: Colors.white);
  TextStyle get _pixelValue =>
      GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white);
  TextStyle get _pixelLabel => GoogleFonts.pressStart2p(
    fontSize: 8,
    color: const Color.fromARGB(255, 255, 255, 255),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: _stoneDark,
        border: Border.all(color: _ironGrey, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. RETRATO DO HERÓI
          Container(
            width: 120,
            height: 190,
            decoration: BoxDecoration(
              border: Border.all(color: _gold.withOpacity(0.6), width: 2),
              boxShadow: [
                BoxShadow(color: _gold.withOpacity(0.1), blurRadius: 10),
              ],
              image: const DecorationImage(
                image: AssetImage('assets/images/fundoheroi.gif'),
                fit: BoxFit.cover,
                opacity: 0.5,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/hero.gif',
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16.0),

          // 2. FICHA DE DADOS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NOME
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("CAÇADOR", style: _pixelLabel.copyWith(color: _gold)),
                    const SizedBox(height: 4),
                    Text(
                      hunter.hunterName.toUpperCase(),
                      style: _pixelTitle.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // BARRAS DE STATUS
                Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.heart,
                      color: _bloodRed,
                      size: 12,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: HealthBar(
                        currentHp: hunter.currentHp,
                        maxHp: hunter.maxHp,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.star,
                      color: _xpGreen,
                      size: 12,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: XpBar(
                        currentXp: hunter.currentXp,
                        nextLevelXp: hunter.nextLevelXp,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // GRID DE INFO (NÍVEL E OURO)
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBadge(
                        "NVL",
                        "${hunter.level}",
                        Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoBadge(
                        "OURO",
                        "${hunter.currentCoins}",
                        _gold,
                        icon: FontAwesomeIcons.coins,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // --- LINHA DO BOTÃO E XP ---
                Row(
                  children: [
                    // Ícone de XP em Dobro (Compacto)
                    _buildCompactXpIndicator(hunter.xpDouble),

                    const SizedBox(width: 10),

                    // Botão de Inventário (Expandido)
                    Expanded(
                      child: SizedBox(
                        height: 35,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InventoryScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              97,
                              168,
                              159,
                            ),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            padding: EdgeInsets.zero,
                            shape: const BeveledRectangleBorder(
                              side: BorderSide(
                                color: Color.fromARGB(123, 255, 255, 255),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 8),
                              Text(
                                'MOCHILA',
                                style: _pixelLabel.copyWith(fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(
    String label,
    String value,
    Color valueColor, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: _panelBg,
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: _pixelLabel.copyWith(fontSize: 6, color: Colors.white38),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 10, color: valueColor),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  value,
                  style: _pixelValue.copyWith(color: valueColor, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Compacto de XP
  Widget _buildCompactXpIndicator(bool isActive) {
    final color = isActive ? Colors.lightBlueAccent : Colors.white24;

    return Container(
      height: 35,
      width: 40, // Largura fixa para manter o alinhamento
      decoration: BoxDecoration(
        color: _panelBg,
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive
                ? FontAwesomeIcons.anglesUp
                : FontAwesomeIcons.minus, // Ícone muda se ativo
            size: 10,
            color: color,
          ),
          const SizedBox(height: 2),
          Text(
            "DOBRO",
            style: GoogleFonts.pixelifySans(
              // Fonte mais compacta para caber
              fontSize: 8,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
