// lib/models/battle_state.dart

class BattleMove {
  final String id;
  final String name;
  final String description;
  final String affinity;

  BattleMove({
    required this.id, 
    required this.name, 
    required this.description, 
    required this.affinity
  });

  factory BattleMove.fromJson(Map<String, dynamic> json) {
    return BattleMove(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Ataque',
      description: json['description'] ?? '',
      affinity: json['affinity'] ?? 'Neutral',
    );
  }
}

class BattleState {
  final int sessionId;
  final String opponentName;
  final int playerHp;
  final int enemyHp;
  final bool finished;
  final bool win;
  final List<String> log;
  
  // --- CAMPO NOVO QUE ESTAVA FALTANDO ---
  final List<BattleMove> availableMoves; 

  BattleState({
    required this.sessionId,
    this.opponentName = '',
    required this.playerHp,
    required this.enemyHp,
    required this.finished,
    required this.win,
    required this.log,
    required this.availableMoves, // Obrigatório agora
  });

  factory BattleState.fromJson(Map<String, dynamic> json) {
    return BattleState(
      sessionId: json['sessionId'] ?? 0,
      opponentName: json['opponentName'] ?? 'Oponente',
      // Verifica maiúsculas e minúsculas por segurança (C# vs Dart)
      playerHp: json['playerHp'] ?? json['PlayerHp'] ?? 0,
      enemyHp: json['enemyHp'] ?? json['EnemyHp'] ?? 0,
      finished: json['finished'] ?? json['Finished'] ?? false,
      win: json['win'] ?? json['Win'] ?? false,
      
      log: json['log'] != null 
          ? List<String>.from(json['log']) 
          : (json['Log'] != null ? List<String>.from(json['Log']) : []),

      // --- LEITURA DA LISTA DE GOLPES ---
      availableMoves: json['availableMoves'] != null
          ? (json['availableMoves'] as List).map((m) => BattleMove.fromJson(m)).toList()
          : (json['AvailableMoves'] != null 
              ? (json['AvailableMoves'] as List).map((m) => BattleMove.fromJson(m)).toList()
              : []), 
    );
  }
}