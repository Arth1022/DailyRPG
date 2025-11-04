import 'package:flutter/material.dart';

class XpProgressBar extends StatelessWidget{
  final int currentXp;
  final int nextLevelXp;

  const XpProgressBar({
    super.key,
    required this.currentXp,
    required this.nextLevelXp,
  });

  @override
  Widget build(BuildContext context){

    double percentage = 0.0;

    if (nextLevelXp > 0){
      percentage = currentXp/ nextLevelXp;
    }

    percentage = percentage.clamp(0.0, 1.0);

    return SizedBox(
      height: 20,
      width: double.infinity,

      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),

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
                color: const Color(0xFFA67C52)
              ),
            ),
            //TEXTO
            Center(
              child: Text(
                "$currentXp | $nextLevelXp XP",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius:2.0,
                      offset: Offset(1.0,1.0)
                    )
                  ]
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
