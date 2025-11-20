class RankingProfile {
  final String hunterName;
  final int level;

  RankingProfile({required this.hunterName, required this.level});

  factory RankingProfile.fromJson(Map<String, dynamic> json) {
    return RankingProfile(
      hunterName: json['hunterName'] ?? 'Desconhecido',
      level: json['level'] ?? 1,
    );
  }
}
