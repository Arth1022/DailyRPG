using Microsoft.EntityFrameworkCore.Metadata.Internal;

namespace DailyRpg.Models
{
    public class HunterUser
    {
        public int Id { get; set; } 
        public string HunterName { get; set; } = "Usuário novo"; 
        public int Level { get; set; } = 1;
        public int CurrentHp { get; set; } = 100; 
        public int MaxHp { get; set; } = 100;
        public int CurrentXp { get; set; } = 0;
        public int NextLevelXp { get; set; } = 700;
        public int CurrentCoins { get; set; } = 0;
        public bool XpDouble { get; set; } = false;
        public int UserId { get; set; }
        public int Damage { get; set; } = 1;
        public int Defense { get; set; } = 0;
        public int? EquippedWeaponSlotId { get; set; } = null;
        public int? EquippedArmorslotId { get; set; } = null;
    }
}
