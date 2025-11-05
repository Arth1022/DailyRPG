// lib/models/contract.dart

class Contract {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final int coinReward;
  final bool isCompleted;
  final DateTime? startDate; // <-- Renomeado de 'dueDate'
  final String difficult;   // <-- Adicionado

  Contract({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.coinReward,
    required this.isCompleted,
    required this.difficult, // <-- Adicionado ao construtor
    this.startDate,         // <-- Renomeado
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      
      // Correção 1: Força o ID (que é 'int' 7) a ser 'String'
      id: json['id']?.toString() ?? '', 
      
      title: json['title']?.toString() ?? 'Sem Título',
      
      // Correção 2: 'descricao' (do JSON) em vez de 'description'
      description: json['descricao']?.toString() ?? 'Sem Descrição', 
      
      xpReward: json['xpReward'] ?? 0,
      coinReward: json['coinReward'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      
      // Correção 3: 'startDate' (do JSON) em vez de 'due_date'
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : null,

      // Correção 4: Adicionado o novo campo 'difficult'
      difficult: json['difficult']?.toString() ?? 'Normal',
    );
  }
}