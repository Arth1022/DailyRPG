class Contract {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final int coinReward;
  final bool isCompleted;
  final DateTime? startDate; 
  final String difficult;  

  Contract({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.coinReward,
    required this.isCompleted,
    required this.difficult, 
    this.startDate,         
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      

      id: json['id']?.toString() ?? '', 
      
      title: json['title']?.toString() ?? 'Sem Título',
      
      description: json['descricao']?.toString() ?? 'Sem Descrição', 
      
      xpReward: json['xpReward'] ?? 0,
      coinReward: json['coinReward'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate']) 
          : null,

      difficult: json['difficult']?.toString() ?? 'Normal',
    );
  }
}