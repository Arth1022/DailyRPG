using System.ComponentModel.DataAnnotations.Schema;
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

        //SKILLS////////////////////
        public int AttributePoints { get; set; } = 0;

        public int Strength { get; set; } = 0;
        public int Dexterity { get; set; } = 0;
        public int Intelligence { get; set; } = 0;
        public int Constitution { get; set; } = 0;
        public int Endurance { get; set; } = 0;


        /// FIM SKILLL//////

        public virtual ICollection<InventorySlot> InventorySlots { get; set; }

        public int? EquippedWeaponSlotId { get; set; } = null;

        public virtual InventorySlot? EquippedWeaponSlot { get; set; } = null!;

        public int? EquippedArmorSlotId { get; set; } = null;

        public virtual InventorySlot? EquippedArmorSlot { get; set; } = null!;
        public int CurrentBossHp { get; set; } = 100;
        public int? CurrentBossId { get; set; } = null;

        [ForeignKey("CurrentBossId")]
        public virtual Boss? CurrentBoss { get; set; } = null!;



    }
}
