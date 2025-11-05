//Construtor da classe HunterUser

class HunterUser {
  final int id;
  final String hunterName;
  final int level;
  final int currentHp;
  final int maxHp;
  final int currentXp;
  final int nextLevelXp;
  final int currentCoins;
  final int healingPotions;
  final int xpPotions;
  final bool xpDouble;

  HunterUser({
    required this.id,
    required this.hunterName,
    required this.level,
    required this.currentHp,
    required this.maxHp,
    required this.currentXp,
    required this.nextLevelXp,
    required this.currentCoins,
    required this.healingPotions,
    required this.xpPotions,
    required this.xpDouble,
  });

  factory HunterUser.fromJson(Map<String, dynamic> json){
    return HunterUser(

      id:json['id'],
      

      hunterName:json['hunterName'], 

      level:json['level'],
      currentHp:json['currentHp'],
      maxHp: json['maxHp'],
      currentXp: json['currentXp'],
      nextLevelXp: json['nextLevelXp'],

      currentCoins: json['currentCoins'], 

      healingPotions: json['healingPotions'],

      xpPotions: json['xpPotions'],

      xpDouble: json['xpDouble']
    );
  }
}