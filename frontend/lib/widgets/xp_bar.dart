import 'package:flutter/material.dart';


class XpProgressBar extends StatelessWidget {
  
  final int currentXp;
  final int nextLevelXp;

  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.nextLevelXp,
  });

  @override
  Widget build(BuildContext context) {
    
    double percentage = 0.0;
    if (nextLevelXp > 0) {
      percentage = currentXp / nextLevelXp;
    }
    percentage = percentage.clamp(0.0, 1.0);

    return Container(
      width: 100,
      height: 25.0,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 15, 15, 15), 
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
                color: const Color.fromARGB(0, 255, 255, 255),
              ),

              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  color: const Color.fromARGB(255, 82, 166, 103),
                ),
              ),

              Center(
                child: Text(
                  "$currentXp / $nextLevelXp XP",
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