using System.ComponentModel.DataAnnotations;

namespace DailyRpg.Models
{
    public enum ItemType
    {
        Consumable,
        Equipament,
        Material,
        Xp

    }

    public enum EquipmentType
    {
        None,
        Weapon,
        Armor,
        Material
    }

    public class Item
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = string.Empty;

        public string Description { get; set; } = string.Empty;

        [Required]
        public ItemType Type { get; set; }

        public EquipmentType EquipType { get; set; } = EquipmentType.None;

        public int EffectValue { get; set; } = 0;

        [Required]
        public int ShopPrice { get; set; }

        public string SkillAffinity { get; set; } = "None";

    }
}