using System.ComponentModel.DataAnnotations;

namespace DailyRpg.Models
{
    public class CreateContractDto
    {
        [Required]
        [MaxLength(100)]
        public string Title { get; set; } = string.Empty;

        [MaxLength(500)]
        public string? Descricao { get; set; }

        [Required]
        public string Difficult { get; set; } = string.Empty; 

        [Required]
        public int XpReward { get; set; } 

        [Required]
        public int CoinReward { get; set; }
    }
}