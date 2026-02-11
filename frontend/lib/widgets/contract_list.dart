import 'package:akar_icons_flutter/akar_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/hunter_provider.dart';
import '../models/contract.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContractList extends StatelessWidget {
  const ContractList({super.key});

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'fácil':
      case 'easy':
        return const Color(0xFF00FF85);
      case 'normal':
      case 'medium':
        return const Color(0xFF00D2FF);
      case 'difícil':
      case 'hard':
        return const Color(0xFFFF9900);
      case 'lendário':
      case 'expert':
      case 'insano':
        return const Color(0xFFFF0055);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pixelTitleStyle = GoogleFonts.pressStart2p(
      fontSize: 12,
      color: Colors.white,
    );
    final pixelBodyStyle = GoogleFonts.pixelifySans(
      fontSize: 14,
      color: Colors.white,
    );
    final pixelLabelStyle = GoogleFonts.pressStart2p(
      fontSize: 9,
      color: Colors.white,
    );

    const cardColor = Color(0xff222222);
    const diamondColor = Color.fromARGB(255, 120, 240, 255);
    const goldColor = Color(0xFFFFD700);

    return Consumer<HunterProvider>(
      builder: (context, provider, child) {
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
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide(
                    color: difficultyColor.withOpacity(0.8),
                    width: 1.5,
                  ),
                ),
                child: ExpansionTile(
                  iconColor: difficultyColor,
                  collapsedIconColor: Colors.white,
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  title: Row(
                    children: [
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
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () {
                          // Chama a função e o Consumer reconstrói a lista automaticamente
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
                          Text(contract.description, style: pixelBodyStyle),
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
                                decorationColor: difficultyColor,
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
                                Row(
                                  children: [
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
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: Colors.white24,
                                ),
                                Row(
                                  children: [
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
                                      ),
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
                                  side: const BorderSide(
                                    color: Color(0xFFB42828),
                                  ),
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
                                    color: Colors.white,
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
      },
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
            border: Border(left: BorderSide(color: decorationColor, width: 2)),
            color: Colors.white.withOpacity(0.05),
          ),
          child: Text(
            value,
            style: fontStyle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
