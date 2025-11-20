using System.ComponentModel.DataAnnotations;

namespace DailyRpg.Models
{
    public class CreateContractDto
    {
        [Required]
        public string Title { get; set; } = string.Empty;

        public string? Descricao { get; set; }

        [Required]
        public string Difficulty { get; set; } = ""; 

        [Required]
        public int XpReward { get; set; } 

        [Required]
        public int CoinReward { get; set; }
    }
}