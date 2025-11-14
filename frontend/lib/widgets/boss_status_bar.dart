import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                style: const TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.redAccent
                ),
              ),
              Text(
                'Nível: ${bossStatus.bossLevel}',
                style: const TextStyle(
                  fontSize: 16, 
                  color: Colors.white
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          LifeBar(
            currentHp: bossStatus.currentHp,
            maxHp: bossStatus.maxHp,
          ),
        ],
      ),
    );
  }
}