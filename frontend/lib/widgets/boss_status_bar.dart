import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:dailyrpg/providers/hunter_provider.dart';
import 'package:dailyrpg/widgets/health_bar.dart';

class BossStatusBar extends StatelessWidget {
  const BossStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final bossStatus = context.watch<HunterProvider>().bossStatus;

    if (bossStatus == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bossStatus.bossName,
                style: GoogleFonts.pressStart2p(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              Text(
                'LVL:${bossStatus.bossLevel}',
                style: GoogleFonts.pressStart2p(
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          HealthBar(currentHp: bossStatus.currentHp, maxHp: bossStatus.maxHp),
        ],
      ),
    );
  }
}
