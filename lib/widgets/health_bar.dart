import 'package:flutter/material.dart';

class LifeBar extends StatelessWidget{
  final int currentHp;
  final int maxHp;

  const LifeBar({
    super.key,
    required this.currentHp,
    required this.maxHp,
  });

  @override
  Widget build(BuildContext context){

    double percentage = 0.0;
    if (maxHp > 0){
      percentage = currentHp / maxHp;
    }
    percentage = percentage.clamp(0, 1);

    return SizedBox(
      width: 70,
      height: 70,

      child: Stack(
        fit: StackFit.expand,
        children: [

          CircularProgressIndicator(
            value: 1,
            strokeWidth: 8,
            backgroundColor: Colors.transparent,
            color: const Color(0xFF4D4033),
          ),

          CircularProgressIndicator(
            value: percentage,
            strokeWidth: 8,
            color: const Color(0xFFE53935),
          ),

          Center(
            child: Text(
              "VIDA",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          )
        ],
      ),
    );
  }
}