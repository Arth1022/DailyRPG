import 'package:akar_icons_flutter/akar_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:dailyrpg/models/contract.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContractList extends StatelessWidget {
  const ContractList({super.key});

  @override
  Widget build(BuildContext context) {
    // Estilos e Cores Replicadas da Loja
    final pixelTitleStyle = GoogleFonts.pressStart2p(
      fontSize: 12,
      color: Colors.white,
    );
    final pixelBodyStyle = GoogleFonts.pixelifySans(
      fontSize: 14,
      color: Colors.white70,
    );
    const pixelPrimaryColor = Color.fromARGB(255, 77, 167, 209); // Azul/Ciano
    const cardColor = Color(0xff222222);
    const redBorderColor = Color.fromARGB(
      255,
      180,
      40,
      40,
    ); // Vermelho da borda
    const diamondColor = Color.fromARGB(
      255,
      120,
      240,
      255,
    ); // Cor ciano para o diamante/XP

    final provider = context.watch<HunterProvider>();
    final List<Contract> contracts = provider.contracts;
    final bool isLoading = provider.isLoading;

    // Obtém o padding inferior da área segura (para evitar a barra de gestos/botões)
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    if (isLoading && contracts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
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
        // Adiciona um padding inferior extra para compensar a área segura inferior e a BottomNavigationBar
        padding: EdgeInsets.only(bottom: bottomPadding + 80),
        itemCount: contracts.length,
        itemBuilder: (context, index) {
          final contract = contracts[index];

          String formattedDate;
          if (contract.startDate != null) {
            final date = contract.startDate!;

            formattedDate =
                "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
          } else {
            formattedDate = "N/A";
          }

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: cardColor,
            // Padrão de Borda Pixelada do Card
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Colors.white24, width: 1),
            ),
            child: ExpansionTile(
              iconColor: pixelPrimaryColor,
              collapsedIconColor: Colors.white,
              title: Row(
                children: [
                  const Icon(AkarIcons.double_sword, color: pixelPrimaryColor),
                  const SizedBox(width: 16),
                  Expanded(child: Text(contract.title, style: pixelTitleStyle)),
                  IconButton(
                    icon: const Icon(
                      FontAwesomeIcons.squareCheck,
                      color: Colors.white70,
                      size: 20,
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contract.description, style: pixelBodyStyle),
                      const SizedBox(height: 10),
                      Text("Início: $formattedDate", style: pixelBodyStyle),
                      const SizedBox(height: 10),
                      // Linha de Recompensa com Ícone de Diamante (XP) e Moeda (Gold)
                      Row(
                        children: [
                          // Recompensa XP (Diamante)
                          Text(
                            "Recompensa: ${contract.xpReward} ",
                            style: pixelBodyStyle.copyWith(
                              color: diamondColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            FontAwesomeIcons.diamond,
                            color: diamondColor,
                            size: 14,
                          ),
                          const SizedBox(
                            width: 15,
                          ), // Espaçamento entre XP e Gold
                          // Recompensa Gold (Moeda)
                          Text(
                            "${contract.coinReward} ",
                            style: pixelBodyStyle.copyWith(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(
                            FontAwesomeIcons.coins,
                            color: Colors.yellow,
                            size: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: Container(
                          // Container simplificado para borda vermelha
                          decoration: BoxDecoration(
                            border: Border.all(color: redBorderColor, width: 2),
                          ),
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
                                60,
                                20,
                                20,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              shape: const BeveledRectangleBorder(
                                borderRadius: BorderRadius.zero,
                                side: BorderSide.none,
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'DESISTIR',
                              style: GoogleFonts.pressStart2p(fontSize: 10),
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
}
