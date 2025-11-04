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

// ... (o seu construtor HunterUser({...}) fica aqui em cima, está perfeito)

  // 3. A "Fábrica" (O Tradutor de JSON) - AGORA CORRIGIDO
  factory HunterUser.fromJson(Map<String, dynamic> json){
    return HunterUser(

      id:json['id'],
      
      // --- CORREÇÃO 1 ---
      // Estava: json['HunterName']
      hunterName:json['hunterName'], 

      level:json['level'],
      currentHp:json['currentHp'],
      maxHp: json['maxHp'],
      currentXp: json['currentXp'],
      nextLevelXp: json['nextLevelXp'],

      // --- CORREÇÃO 2 ---
      // Estava: json['coins']
      currentCoins: json['currentCoins'], 

      healingPotions: json['healingPotions'],
      
      // Você deu nomes diferentes no C# (XpPotions) e no Dart (xpPotions)
      // O JSON será "xpPotions", então o seu Dart está CORRETO aqui.
      xpPotions: json['xpPotions'],
      
      // O JSON será "xpDouble", o seu Dart está CORRETO aqui.
      xpDouble: json['xpDouble']
    );
  }
}