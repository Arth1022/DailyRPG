import 'package:flutter/material.dart';

class LifeBar extends StatelessWidget {
  
  final int currentHp;
  final int maxHp;

  const LifeBar({
    super.key,
    required this.currentHp,
    required this.maxHp,
  });

  @override
  Widget build(BuildContext context) {
    
    double percentage = 0.0;
    if (maxHp > 0) {
      percentage = currentHp / maxHp;
    }
    percentage = percentage.clamp(0.0, 1.0);

    return Container(
      width: 100,
      height: 25.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      
      child: Padding(
        padding: const EdgeInsets.all(2.0),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0), 
          
          child: Stack(
            fit: StackFit.expand,
            children: [
              
              Container(
                color: const Color(0xFF4D4033),
              ),

              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  color: const Color(0xFFE53935),
                ),
              ),

              Center(
                child: Text(
                  "$currentHp / $maxHp",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 2.0,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}