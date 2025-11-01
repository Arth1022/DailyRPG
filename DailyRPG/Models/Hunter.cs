using System.Data;

namespace DailyRpg.Models
{
    public class HunterUser
    {
        public required int Id { get; set; }
        public required string HunterName { get; set; }

        public required int CurrentHp { get; set; } = 100;

        public required int Level { get; set; } = 1;

        public int? CurrentCoins { get; set; } = 0;

        public int? CurrentXp { get; set; } = 0;

    }
}