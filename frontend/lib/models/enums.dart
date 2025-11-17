enum ItemType { Consumable, Equipment, Material, XP, Unknown }

enum EquipmentType { None, Weapon, Armor, Unknown }

ItemType itemTypeFromInt(int value) {
  switch (value) {
    case 0:
      return ItemType.Consumable;
    case 1:
      return ItemType.Equipment;
    case 2:
      return ItemType.Material;
    case 3:
      return ItemType.XP;
    default:
      return ItemType.Unknown;
  }
}

EquipmentType equipTypeFromInt(int value) {
  switch (value) {
    case 0:
      return EquipmentType.None;
    case 1:
      return EquipmentType.Weapon;
    case 2:
      return EquipmentType.Armor;
    default:
      return EquipmentType.Unknown;
  }
}
