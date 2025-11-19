namespace DailyRpg.Models
{
    public class BattleMove
    {
        public string Id { get; set; }        // ex: "fireball"
        public string Name { get; set; }      // ex: "Bola de Fogo"
        public string Description { get; set; }
        public string Affinity { get; set; }  // "Intelligence", "Strength", etc
        public double DamageMultiplier { get; set; } // 1.0 = normal, 1.5 = 50% mais forte
        public int Accuracy { get; set; }     // Chance de acertar (0-100)
    }
}