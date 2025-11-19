using System.Collections.Generic;
using DailyRpg.Models;

namespace DailyRpg.Helpers
{
    public static class MoveFactory
    {
        public static List<BattleMove> GetMovesForAffinity(string affinity)
        {
            var moves = new List<BattleMove>();

            moves.Add(new BattleMove { Id = "basic", Name = "Ataque Básico", Description = "Um ataque simples.", Affinity = "Neutral", DamageMultiplier = 1.0, Accuracy = 95 });

            switch (affinity?.ToLower())
            {
                case "intelligence": // Mago
                    moves.Add(new BattleMove { Id = "magic_missile", Name = "Míssil Mágico", Description = "Dano garantido, mas baixo.", Affinity = "Intelligence", DamageMultiplier = 0.8, Accuracy = 100 });
                    moves.Add(new BattleMove { Id = "fireball", Name = "Bola de Fogo", Description = "Alto dano, chance de errar.", Affinity = "Intelligence", DamageMultiplier = 1.6, Accuracy = 75 });
                    moves.Add(new BattleMove { Id = "frost_nova", Name = "Nova Gélida", Description = "Dano em área (simulado).", Affinity = "Intelligence", DamageMultiplier = 1.2, Accuracy = 90 });
                    break;

                case "dexterity": // Ladino/Arqueiro
                    moves.Add(new BattleMove { Id = "quick_stab", Name = "Estocada Rápida", Description = "Muito preciso.", Affinity = "Dexterity", DamageMultiplier = 1.1, Accuracy = 100 });
                    moves.Add(new BattleMove { Id = "poison_dagger", Name = "Adaga Envenenada", Description = "Dano traiçoeiro.", Affinity = "Dexterity", DamageMultiplier = 1.3, Accuracy = 85 });
                    moves.Add(new BattleMove { Id = "headshot", Name = "Tiro na Cabeça", Description = "Dano massivo, difícil de acertar.", Affinity = "Dexterity", DamageMultiplier = 2.0, Accuracy = 50 });
                    break;

                case "strength": // Guerreiro
                default: // Padrão se estiver desarmado
                    moves.Add(new BattleMove { Id = "heavy_smash", Name = "Esmagar", Description = "Golpe pesado.", Affinity = "Strength", DamageMultiplier = 1.4, Accuracy = 80 });
                    moves.Add(new BattleMove { Id = "cleave", Name = "Corte Amplo", Description = "Dano consistente.", Affinity = "Strength", DamageMultiplier = 1.2, Accuracy = 90 });
                    moves.Add(new BattleMove { Id = "execute", Name = "Executar", Description = "Tenta finalizar o oponente.", Affinity = "Strength", DamageMultiplier = 1.8, Accuracy = 60 });
                    break;
            }

            return moves;
        }
    }
}