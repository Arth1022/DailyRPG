import 'package:dailyrpg/screens/inventory_screen.dart';
import '../screens/craft_screen.dart';
import 'package:flutter/material.dart';
import '../models/hunter_user.dart';
import 'health_bar.dart';
import 'xp_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



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
              Icon(FontAwesomeIcons.userShield),
              SizedBox(width: 14,),
              Text(
                "${hunter.hunterName}",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              )
            ],
          ),
          const Divider(height: 20),
          SizedBox(height: 25,),
          Row(
            children: [
              const Icon(
                FontAwesomeIcons.heartPulse,
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
                FontAwesomeIcons.diamond,
                color: Color.fromARGB(255, 85, 166, 82),
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
                  FontAwesomeIcons.book,
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
                  FontAwesomeIcons.coins,
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
                SizedBox(width: 150,),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.layerGroup),
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