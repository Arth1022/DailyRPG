using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DailyRpg.Models
{
    public class Contract
    {
        public  int Id { get; set; } = 0;
        public required string Title { get; set; }
        public string? Descricao { get; set; }
        public required int XpReward { get; set; } = 100;
        public required int CoinReward { get; set; } = 100;
        public DateTime StartDate { get; set; }

        public DateTime? CompletedAt { get; set; }
        public required bool IsCompleted { get; set; } = false;
        public string Difficulty { get; set; } = "medium";
        [Required]
        public int HunterUserId { get; set; }
        
        [ForeignKey("HunterUserId")]
        public virtual HunterUser HunterUser { get; set; } = null!;
    }
}