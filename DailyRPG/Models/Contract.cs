namespace DailyRpg.Models
{
    public class Contract
    {
        public required int Id {get; set;}
        public required string Title { get; set; }
        public string? Descricao { get; set; }

        public required int XpReward { get; set; } = 100;

        public required int CoinReward { get; set; } = 100;

        public DateTime StartDate { get; set; }

        public DateTime EndDate { get; set; }

        public required bool IsComplet { get; set; } = false;
    }
}