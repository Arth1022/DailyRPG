using System.ComponentModel.DataAnnotations;

namespace DailyRpg.Models
{
    public class CreateContractDto
    {
        [Required]
        [MaxLength(100)]
        public string Title { get; set; } = string.Empty;

        [MaxLength(500)]
        public string? Descricao { get; set; } // <-- O SEU NOME

        [Required]
        public string Difficult { get; set; } = string.Empty; // <-- O SEU NOME

        [Required]
        public int XpReward { get; set; } // <-- O SEU NOME

        [Required]
        public int CoinReward { get; set; } // <-- O SEU NOME
    }
}