using System;

namespace DailyRpg.Models
{
    public class BattleSession
    {
        public int Id { get; set; }
        
        public int HunterId { get; set; } 
        public int OpponentId { get; set; } 


        public int PlayerCurrentHp { get; set; }
        public int EnemyCurrentHp { get; set; }

        public int PlayerMaxHp { get; set; }
        public int EnemyMaxHp { get; set; }
        
        public bool IsFinished { get; set; } = false;
        public bool PlayerWon { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}