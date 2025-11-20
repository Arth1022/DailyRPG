import 'package:akar_icons_flutter/akar_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:dailyrpg/models/contract.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContractList extends StatelessWidget {
  const ContractList({super.key});

  // Define a cor baseada na dificuldade (apenas para decoração agora)
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'fácil':
      case 'easy':
        return const Color(0xFF00FF85); // Verde Neon
      case 'normal':
      case 'medium':
        return const Color(0xFF00D2FF); // Azul Ciano
      case 'difícil':
      case 'hard':
        return const Color(0xFFFF9900); // Laranja
      case 'lendário':
      case 'expert':
      case 'insano':
        return const Color(0xFFFF0055); // Vermelho Neon
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ESTILOS: Todos agora usam Colors.white explicitamente
    final pixelTitleStyle = GoogleFonts.pressStart2p(
      fontSize: 12,
      color: Colors.white, // Branco puro
    );
    final pixelBodyStyle = GoogleFonts.pixelifySans(
      fontSize: 14,
      color: Colors.white, // Branco puro
    );
    final pixelLabelStyle = GoogleFonts.pressStart2p(
      fontSize: 9,
      color: Colors.white, // Branco puro
    );

    const cardColor = Color(0xff222222);
    const diamondColor = Color.fromARGB(255, 120, 240, 255);
    const goldColor = Color(0xFFFFD700);

    final provider = context.watch<HunterProvider>();
    final List<Contract> contracts = provider.contracts;
    final bool isLoading = provider.isLoading;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    if (isLoading && contracts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (contracts.isEmpty) {
      return Center(
        child: Text(
          'Nenhum contrato ativo',
          style: pixelTitleStyle.copyWith(fontSize: 10),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.only(bottom: bottomPadding + 80),
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          final contract = contracts[index];

          // Cor decorativa baseada na dificuldade
          final difficultyColor = _getDifficultyColor(contract.difficult);

          String formattedDate;
          if (contract.startDate != null) {
            final date = contract.startDate!;
            formattedDate =
                "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
          } else {
            formattedDate = "--/--";
          }

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: cardColor,
            // Borda colorida mantida para identificar a dificuldade
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(
                color: difficultyColor.withOpacity(0.8),
                width: 1.5,
              ),
            ),
            child: ExpansionTile(
              // A seta (ícone) mantém a cor para dar destaque
              iconColor: difficultyColor,
              collapsedIconColor: Colors.white,
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              title: Row(
                children: [
                  // Ícone colorido para identificação visual rápida
                  Icon(
                    AkarIcons.double_sword,
                    color: difficultyColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      contract.title,
                      style: pixelTitleStyle.copyWith(height: 1.5),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      FontAwesomeIcons.squareCheck,
                      color: Colors.white, // Ícone de check branco
                      size: 22,
                    ),
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<HunterProvider>().completeContract(
                              contract.id,
                            );
                          },
                  ),
                ],
              ),
              children: [
                Container(
                  color: Colors.black12,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("MISSÃO:", style: pixelLabelStyle),
                      const SizedBox(height: 6),
                      Text(
                        contract.description,
                        style: pixelBodyStyle, // Texto branco
                      ),

                      const SizedBox(height: 16),

                      Divider(
                        color: difficultyColor.withOpacity(0.3),
                        thickness: 1,
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildAttributeBadge(
                            label: "RANK",
                            value: contract.difficult.toUpperCase(),
                            decorationColor:
                                difficultyColor, // Cor usada apenas na decoração
                            fontStyle: pixelBodyStyle,
                            labelStyle: pixelLabelStyle,
                          ),
                          _buildAttributeBadge(
                            label: "DATA INÍCIO",
                            value: formattedDate,
                            decorationColor: Colors.white,
                            fontStyle: pixelBodyStyle,
                            labelStyle: pixelLabelStyle,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Painel de Recompensas
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // XP
                            Row(
                              children: [
                                // Ícone mantém a cor original para diferenciar
                                Icon(
                                  FontAwesomeIcons.diamond,
                                  color: diamondColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "+${contract.xpReward} XP",
                                  style: pixelBodyStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ), // Texto Branco
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 20,
                              color: Colors.white24,
                            ),
                            // Gold
                            Row(
                              children: [
                                // Ícone mantém a cor original
                                const Icon(
                                  FontAwesomeIcons.coins,
                                  color: goldColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "+${contract.coinReward} G",
                                  style: pixelBodyStyle.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ), // Texto Branco
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: SizedBox(
                          height: 30,
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context
                                        .read<HunterProvider>()
                                        .surrenderContract(contract.id);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                50,
                                10,
                                10,
                              ),
                              side: const BorderSide(color: Color(0xFFB42828)),
                              shape: const BeveledRectangleBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'ABANDONAR MISSÃO',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 10,
                                color: Colors.white, // Texto do botão branco
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttributeBadge({
    required String label,
    required String value,
    required Color decorationColor, 
    required TextStyle fontStyle,
    required TextStyle labelStyle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            // A barra lateral colorida indica a dificuldade
            border: Border(left: BorderSide(color: decorationColor, width: 2)),
            color: Colors.white.withOpacity(0.05), // Fundo muito sutil
          ),
          child: Text(
            value,
            style: fontStyle.copyWith(
              color: Colors.white, // Texto sempre branco
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
