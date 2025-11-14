import 'inventory_slot.dart';

class HunterUser {
  final int id;
  final String hunterName;
  final int level;
  final int currentXp;
  final int nextLevelXp;
  final int currentCoins;
  final int maxHp;
  final int currentHp;
  final int damage;
  final int defense;
  final int attributePoints;

  final int strength;
  final int dexterity;
  final int intelligence;
  final int constitution;
  final int endurance;

  final int userId;
  final bool xpDouble;

  final int? equippedWeaponSlotId;
  final InventorySlot? equippedWeaponSlot;
  final int? equippedArmorSlotId;
  final InventorySlot? equippedArmorSlot;


  HunterUser({
    required this.id,
    required this.hunterName,
    required this.level,
    required this.currentXp,
    required this.nextLevelXp,
    required this.currentCoins,
    required this.maxHp,
    required this.currentHp,
    required this.damage,
    required this.defense,
    required this.attributePoints,
    required this.strength,
    required this.dexterity,
    required this.intelligence,
    required this.constitution,
    required this.endurance,
    required this.userId,
    required this.xpDouble,
    

    this.equippedWeaponSlotId,
    this.equippedWeaponSlot,
    this.equippedArmorSlotId,
    this.equippedArmorSlot,

  });

  factory HunterUser.fromJson(Map<String, dynamic> json) {
    return HunterUser(
      id: json['id'] ?? 0,
      hunterName: json['hunterName'] ?? 'Caçador',
      level: json['level'] ?? 1,
      currentXp: json['currentXp'] ?? 0,
      nextLevelXp: json['nextLevelXp'] ?? 100,
      currentCoins: json['currentCoins'] ?? 0,
      maxHp: json['maxHp'] ?? 100,
      currentHp: json['currentHp'] ?? 100,
      damage: json['damage'] ?? 1,
      defense: json['defense'] ?? 0,
      attributePoints: json['attributePoints'] ?? 0,
      
      strength: json['strength'] ?? 0,
      dexterity: json['dexterity'] ?? 0,
      intelligence: json['intelligence'] ?? 0,
      constitution: json['constitution'] ?? 0,
      endurance: json['endurance'] ?? 0,

      userId: json['userId'] ?? 0,
      xpDouble: json['xpDouble'] ?? false,

      equippedWeaponSlotId: json['equippedWeaponSlotId'], 
      
      equippedArmorSlotId: json['equippedArmorSlotId'], 


      equippedWeaponSlot: json['equippedWeaponSlot'] != null 
        ? InventorySlot.fromJson(json['equippedWeaponSlot']) 
        : null,
      
      equippedArmorSlot: json['equippedArmorSlot'] != null 
        ? InventorySlot.fromJson(json['equippedArmorSlot']) 
        : null,
 
    );
  }
}