using DailyRpg.Data;
using DailyRpg.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using DailyRpg.Helpers;

namespace DailyRpg.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class BattleController : ControllerBase
    {
        private readonly ApiDbContext _context;

        public BattleController(ApiDbContext context)
        {
            _context = context;
        }

        [HttpPost("start")]
        public async Task<IActionResult> StartBattle()
        {
            (var myId, var error) = _getUserClaims();
            if (error != null) return error;

            var me = await _context.StatsUser
                .Include(u => u.EquippedWeaponSlot)
                .ThenInclude(s => s.Item)
                .FirstOrDefaultAsync(u => u.Id == myId);
            
            var opponent = await _context.StatsUser
                .Where(u => u.Id != myId && u.Level >= me.Level - 2 && u.Level <= me.Level + 2)
                .OrderBy(r => Guid.NewGuid())
                .FirstOrDefaultAsync();
            
            if (opponent == null) opponent = await _context.StatsUser.Where(u => u.Id != myId).FirstOrDefaultAsync();

            if (me == null || opponent == null) return BadRequest("Erro ao iniciar luta.");

            string affinity = me.EquippedWeaponSlot?.Item?.SkillAffinity ?? "Strength";
            var myMoves = MoveFactory.GetMovesForAffinity(affinity);

            var oldSessions = _context.BattleSession.Where(b => b.HunterId == myId);
            _context.BattleSession.RemoveRange(oldSessions);

            var session = new BattleSession
            {
                HunterId = me.Id,
                OpponentId = opponent.Id,
                PlayerCurrentHp = me.MaxHp,
                PlayerMaxHp = me.MaxHp,
                EnemyCurrentHp = opponent.MaxHp,
                EnemyMaxHp = opponent.MaxHp,
                IsFinished = false
            };

            _context.BattleSession.Add(session);
            await _context.SaveChangesAsync();

            return Ok(new { 
                SessionId = session.Id, 
                OpponentName = opponent.HunterName,
                PlayerHp = session.PlayerCurrentHp,
                EnemyHp = session.EnemyCurrentHp,
                AvailableMoves = myMoves
            });
        }

        [HttpPost("{sessionId}/action")]
        public async Task<IActionResult> PerformAction(int sessionId, [FromBody] BattleActionRequest request)
        {
            var session = await _context.BattleSession.FindAsync(sessionId);
            if (session == null || session.IsFinished) return BadRequest("Batalha inválida ou já terminada.");

            // 1. CARREGAMENTO (Mantemos os Includes de Inventário e Arma)
            var me = await _context.StatsUser
                .Include(u => u.EquippedWeaponSlot).ThenInclude(s => s.Item)
                .Include(u => u.InventorySlots).ThenInclude(i => i.Item)
                .FirstOrDefaultAsync(u => u.Id == session.HunterId);
            
            var enemy = await _context.StatsUser
                .Include(u => u.EquippedWeaponSlot).ThenInclude(s => s.Item) // Bot precisa da arma para saber os golpes
                .FirstOrDefaultAsync(u => u.Id == session.OpponentId);

            if (me == null || enemy == null) return BadRequest("Erro ao carregar lutadores.");

            string myAffinity = me.EquippedWeaponSlot?.Item?.SkillAffinity ?? "Strength";
            var myMoves = MoveFactory.GetMovesForAffinity(myAffinity);

            var log = new List<string>();
            bool playerDefending = false;
            
            // --- 2. TURNO DO JOGADOR (Mantido igual, resumido aqui para poupar espaço) ---
            if (request.ActionType == "move")
            {
                var selectedMove = myMoves.FirstOrDefault(m => m.Id == request.MoveId) ?? myMoves[0];
                log.Add($"Você usou {selectedMove.Name}!");
                if (new Random().Next(1, 101) <= selectedMove.Accuracy)
                {
                    int attr = (myAffinity == "Intelligence") ? me.Intelligence : (myAffinity == "Dexterity" ? me.Dexterity : me.Strength);
                    double baseDmg = me.Damage + (attr / 2.0);
                    int damage = (int)(baseDmg * selectedMove.DamageMultiplier);
                    if (new Random().Next(1, 21) == 20) { damage *= 2; log.Add("CRÍTICO!!!"); }
                    session.EnemyCurrentHp -= damage;
                    log.Add($"Acertou! Causou {damage} de dano.");
                }
                else log.Add("Errou o ataque!");
            }
            else if (request.ActionType == "item")
            {
                 var slot = me.InventorySlots.FirstOrDefault(s => s.ItemId == request.ItemId);
                 // ... (Sua lógica de item corrigida anteriormente) ...
                 if (slot != null && slot.Quantity > 0 && session.PlayerCurrentHp < me.MaxHp)
                 {
                     slot.Quantity--;
                     if(slot.Quantity <= 0) _context.InventorySlots.Remove(slot);
                     else _context.Entry(slot).State = EntityState.Modified;

                     int heal = (int)(me.MaxHp * 0.4);
                     if (slot.Item.EffectValue > 0) heal = slot.Item.EffectValue;
                     session.PlayerCurrentHp += heal;
                     if (session.PlayerCurrentHp > me.MaxHp) session.PlayerCurrentHp = me.MaxHp;
                     log.Add($"Você recuperou {heal} HP.");
                 }
                 else log.Add("Não foi possível usar o item.");
            }
            else if (request.ActionType == "defend")
            {
                playerDefending = true;
                log.Add("Você assumiu postura defensiva!");
            }

            if (session.EnemyCurrentHp <= 0)
            {
                await FinishBattle(session, true, me, enemy);
                return Ok(new { SessionId = session.Id, OpponentName = enemy.HunterName, Finished = true, Win = true, Log = log, AvailableMoves = myMoves, PlayerHp = session.PlayerCurrentHp, EnemyHp = 0 });
            }

            // --- 3. TURNO DO INIMIGO (AGORA INTELIGENTE E FURIOSO) ---
            
            bool botHealed = false;
            
            // IA DE CURA: Se HP < 40%, 30% chance de curar
            if (session.EnemyCurrentHp < (enemy.MaxHp * 0.4) && new Random().NextDouble() < 0.3)
            {
                int heal = (int)(enemy.MaxHp * 0.3);
                session.EnemyCurrentHp += heal;
                if (session.EnemyCurrentHp > enemy.MaxHp) session.EnemyCurrentHp = enemy.MaxHp;
                log.Add($"{enemy.HunterName} bebeu uma poção e curou {heal} HP!");
                botHealed = true;
            }

            if (!botHealed)
            {
                // IA DE DEFESA: 15% de chance de defender (Reduzido pois agora ele ataca melhor)
                if (new Random().NextDouble() < 0.15) 
                {
                    log.Add($"{enemy.HunterName} levantou a guarda!");
                    // (Futuramente: enemyDefending = true)
                }
                else // HORA DO ATAQUE
                {
                    // 1. Descobrir a classe do Bot (Pela arma dele)
                    string botAffinity = enemy.EquippedWeaponSlot?.Item?.SkillAffinity ?? "Strength";
                    var botMoves = MoveFactory.GetMovesForAffinity(botAffinity);

                    // 2. Verificar FÚRIA (HP < 20%)
                    bool isEnraged = session.EnemyCurrentHp < (enemy.MaxHp * 0.2);
                    
                    BattleMove botMove;

                    if (isEnraged)
                    {
                        // Lógica de Fúria: Escolhe um dos ataques mais fortes
                        var strongMoves = botMoves.Where(m => m.DamageMultiplier >= 1.2).ToList();
                        
                        if (strongMoves.Any())
                        {
                            botMove = strongMoves[new Random().Next(strongMoves.Count)];
                        }
                        else
                        {
                            // BLINDAGEM: Se não houver golpes fortes, pega o primeiro disponível em vez de quebrar
                            botMove = botMoves.FirstOrDefault() ?? new BattleMove { Name = "Soco de Emergência", Accuracy = 100, DamageMultiplier = 1.0, Affinity = "Neutral" };
                        }

                        log.Add($"⚠️ {enemy.HunterName} ESTÁ FURIOSO!");
                    }
                    else
                    {
                        // Normal: Escolhe qualquer ataque aleatório
                        if (botMoves.Any())
                            botMove = botMoves[new Random().Next(botMoves.Count)];
                        else 
                            botMove = new BattleMove { Name = "Soco de Emergência", Accuracy = 100, DamageMultiplier = 1.0, Affinity = "Neutral" };
                    }

                    log.Add($"{enemy.HunterName} usou {botMove.Name}!");

                    // 3. Calcular Precisão (Accuracy)
                    int hitChance = botMove.Accuracy;
                    
                    // Bônus de precisão na Fúria (Fica mais focado)
                    if (isEnraged) hitChance += 20; 

                    // Rolar o dado de acerto
                    int roll = new Random().Next(1, 101);
                    
                    // Verificamos se acertou (Roll tem que ser menor ou igual a Chance)
                    if (roll <= hitChance)
                    {
                        // 4. Calcular Dano Baseado no Atributo do Bot
                        int botAttr = 0;
                        if (botMove.Affinity == "Intelligence") botAttr = enemy.Intelligence;
                        else if (botMove.Affinity == "Dexterity") botAttr = enemy.Dexterity;
                        else botAttr = enemy.Strength;

                        double baseDmg = enemy.Damage + (botAttr / 2.0);
                        
                        // Aplica multiplicador do golpe (Bola de fogo bate mais que Soco)
                        int totalDmg = (int)(baseDmg * botMove.DamageMultiplier);

                        // Crítico (5% de chance)
                        if (new Random().Next(1, 21) == 20)
                        {
                            totalDmg *= 2;
                            log.Add("CRÍTICO DO INIMIGO!!!");
                        }

                        // Redução se Player defendeu
                        if (playerDefending) totalDmg = (int)(totalDmg * 0.6); // Reduz 40%

                        if (totalDmg < 1) totalDmg = 1;

                        session.PlayerCurrentHp -= totalDmg;
                        log.Add($"Você sofreu {totalDmg} de dano.");
                    }
                    else
                    {
                        log.Add($"{enemy.HunterName} errou o ataque!");
                    }
                }
            }

            if (session.PlayerCurrentHp <= 0)
            {
                session.PlayerCurrentHp = 0;
                await FinishBattle(session, false, me, enemy);
                return Ok(new { SessionId = session.Id, OpponentName = enemy.HunterName, Finished = true, Win = false, Log = log, AvailableMoves = myMoves, PlayerHp = 0, EnemyHp = session.EnemyCurrentHp });
            }

            await _context.SaveChangesAsync();

            return Ok(new 
            { 
                SessionId = session.Id, 
                OpponentName = enemy.HunterName, 
                Finished = false, 
                PlayerHp = session.PlayerCurrentHp, 
                EnemyHp = session.EnemyCurrentHp, 
                Log = log, 
                AvailableMoves = myMoves 
            });
        }

        private async Task FinishBattle(BattleSession session, bool win, HunterUser me, HunterUser enemy)
        {
            session.IsFinished = true;
            session.PlayerWon = win;
            
            if (win)
            {
                int xp = 50 + (enemy.Level * 10);
                int gold = 20 + (enemy.Level * 5);
                me.CurrentXp += xp;
                me.CurrentCoins += gold;
            }
            
            await _context.SaveChangesAsync();
        }

        private (int? hunterId, IActionResult? error) _getUserClaims()
        {
            var identity = HttpContext.User.Identity as ClaimsIdentity;
            if (identity == null) return (null, Unauthorized("Token inválido"));
            var userClaim = identity.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier);
            if (userClaim == null) return (null, Unauthorized("Token inválido"));
            if (!int.TryParse(userClaim.Value, out int userId)) return (null, BadRequest("ID inválido"));
            return (userId, null);
        }
    }

    public class BattleActionRequest
    {
        public string ActionType { get; set; }
        public string? MoveId { get; set; }
        public int? ItemId { get; set; }
    }
}