import 'enums.dart';

class Item {

  final int id;
  final String name;
  final String description; 
  final int effectValue;
  final int shopPrice;
  final String skillAffinity; 

  final ItemType type;
  final EquipmentType equipType;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.equipType,
    required this.effectValue,
    required this.shopPrice,
    required this.skillAffinity,
  });

  factory Item.fromJson(Map<String, dynamic> json) {

      return Item(

        id: json['id'],

        name: json['name'],

        description: json['description'] ?? '',
        
        type: itemTypeFromInt(json['type']),
        
        equipType: equipTypeFromInt(json['equipType']),

        effectValue: json['effectValue'],
        shopPrice: json['shopPrice'],
        skillAffinity: json['skillAffinity'] ?? 'None',
      );
    }
}