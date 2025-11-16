class BossStatus {

  final String bossName;  
  final int bossLevel; 
  final int currentHp;
  final int maxHp;     
  final int rewardXp;
  final int rewardCoin;


  BossStatus({
    required this.bossName,
    required this.bossLevel,
    required this.currentHp,
    required this.maxHp,
    required this.rewardXp,
    required this.rewardCoin,
  });


  factory BossStatus.fromJson(Map<String, dynamic> json) {
    return BossStatus(

      bossName: json['bossName'] ?? 'Chefe Desconhecido',
      bossLevel: json['bossLevel'] ?? 1,
      currentHp: json['currentHp'] ?? 0,
      maxHp: json['maxHp'] ?? 100,
      rewardCoin: json['rewardCoin'] ?? 50,
      rewardXp: json['rewardXp'] ?? 100
    );
  }
}