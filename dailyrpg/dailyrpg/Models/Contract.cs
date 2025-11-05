namespace DailyRpg.Models
{
    public class Contract
    {
        public required int Id { get; set; } = 0;
        public required string Title { get; set; }
        public string? Descricao { get; set; }
        public required int XpReward { get; set; } = 100;
        public required int CoinReward { get; set; } = 100;
        public DateTime StartDate { get; set; }
        public required bool IsCompleted { get; set; } = false;
        public required string Difficult { get; set; } = "Easy";
    }
}