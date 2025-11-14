import 'package:dailyrpg/screens/inventory_screen.dart';
import '../screens/craft_screen.dart';
import 'package:flutter/material.dart';
import '../models/hunter_user.dart';
import 'health_bar.dart';
import 'xp_bar.dart';

class HunterHeader extends StatelessWidget {
  final HunterUser hunter;

  const HunterHeader({
    super.key,
    required this.hunter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "${hunter.hunterName}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
          SizedBox(height: 6.5,),
          Row(
            children: [
              const Icon(
                Icons.favorite,
                color: Color(0xFFE53935),
                size: 25.0,
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: LifeBar(
                  currentHp: hunter.currentHp,
                  maxHp: hunter.maxHp,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20.0),
          Row(
            children: [
              const Icon(
                Icons.auto_stories,
                color: Color(0xFFA67C52),
                size: 25.0,
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: XpProgressBar(
                  currentXp: hunter.currentXp,
                  nextLevelXp: hunter.nextLevelXp,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_moon,
                  color: Color.fromARGB(255, 11, 223, 21),
                  size: 25.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  '${hunter.level}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 11, 223, 21),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 20.0),
                const Icon(
                  Icons.monetization_on,
                  color: Colors.amber,
                  size: 20,
                ),
                Text(
                  ' ${hunter.currentCoins}G',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.work_outline),
                  iconSize: 30.0,
                  color: Colors.grey[300],
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InventoryScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}