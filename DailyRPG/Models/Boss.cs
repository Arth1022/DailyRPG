using System.ComponentModel.DataAnnotations;

namespace DailyRpg.Models
{
    public class Boss
    {
        [Key]
        public int Id { get; set; } 

        [Required]
        public string Name { get; set; } = string.Empty;

        [Required]
        public int Level { get; set; }

        [Required]
        public int MaxHp { get; set; } 
        [Required]
        public int RewardXp { get; set; } 

        [Required]
        public int RewardCoin { get; set; } 

        public int? NextBossId { get; set; } = null; 
    }
}