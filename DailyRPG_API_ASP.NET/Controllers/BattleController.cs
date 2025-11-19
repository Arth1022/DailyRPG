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

            var me = await _context.StatsUser
                .Include(u => u.EquippedWeaponSlot)      
                .ThenInclude(s => s.Item)                
                .FirstOrDefaultAsync(u => u.Id == session.HunterId);
            
            var enemy = await _context.StatsUser.FindAsync(session.OpponentId);

            if (me == null || enemy == null) return BadRequest("Erro ao carregar lutadores.");

            string affinity = me.EquippedWeaponSlot?.Item?.SkillAffinity ?? "Strength";
            var myMoves = MoveFactory.GetMovesForAffinity(affinity);

            var log = new List<string>();
            bool playerDefending = false;

            if (request.ActionType == "move")
            {
                var selectedMove = myMoves.FirstOrDefault(m => m.Id == request.MoveId);
                if (selectedMove == null) selectedMove = myMoves[0];

                log.Add($"Você usou {selectedMove.Name}!");

                int hitRoll = new Random().Next(1, 101);
                
                if (hitRoll <= selectedMove.Accuracy)
                {
                    int attributeDmg = 0;
                    if (affinity == "Intelligence") attributeDmg = me.Intelligence;
                    else if (affinity == "Dexterity") attributeDmg = me.Dexterity;
                    else attributeDmg = me.Strength;

                    double baseDmg = (me.Damage + (attributeDmg / 2.0));
                    int totalDmg = (int)(baseDmg * selectedMove.DamageMultiplier);

                    bool isCrit = new Random().Next(1, 21) == 20;
                    if (isCrit) 
                    {
                        totalDmg *= 2;
                        log.Add("CRÍTICO!!!");
                    }

                    session.EnemyCurrentHp -= totalDmg;
                    log.Add($"Acertou! Causou {totalDmg} de dano.");
                }
                else
                {
                    log.Add("Errou o ataque!");
                }
            }
            else if (request.ActionType == "potion")
            {
                int healAmount = (int)(me.MaxHp * 0.3);
                session.PlayerCurrentHp += healAmount;
                if (session.PlayerCurrentHp > me.MaxHp) session.PlayerCurrentHp = me.MaxHp;
                log.Add($"Você bebeu uma poção e recuperou {healAmount} HP.");
            }
            else if (request.ActionType == "defend")
            {
                playerDefending = true;
                log.Add("Você assumiu postura defensiva!");
            }

            if (session.EnemyCurrentHp <= 0)
            {
                await FinishBattle(session, true, me, enemy);
                return Ok(new { 
                    SessionId = session.Id, 
                    OpponentName = enemy.HunterName, 
                    Finished = true, 
                    Win = true, 
                    Log = log,
                    PlayerHp = session.PlayerCurrentHp,
                    EnemyHp = 0,
                    AvailableMoves = myMoves
                });
            }

            int botHitRoll = new Random().Next(1, 21);
            int botStrMod = (enemy.Strength - 10) / 2;
            int botHitTotal = botHitRoll + botStrMod;

            int myDexMod = (me.Dexterity - 10) / 2;
            int myAC = 10 + myDexMod + me.Defense;
            
            if (playerDefending) myAC += 5;

            if (botHitRoll == 20 || botHitTotal >= myAC)
            {
                int botDmg = new Random().Next(1, Math.Max(2, enemy.Damage) + 1) + botStrMod;
                if (botHitRoll == 20) botDmg *= 2;
                if (botDmg < 1) botDmg = 1;

                session.PlayerCurrentHp -= botDmg;
                log.Add($"{enemy.HunterName} atacou e causou {botDmg} de dano!");
            }
            else
            {
                 log.Add($"{enemy.HunterName} errou o ataque!");
            }

            if (session.PlayerCurrentHp <= 0)
            {
                session.PlayerCurrentHp = 0;
                await FinishBattle(session, false, me, enemy);
                return Ok(new { 
                    SessionId = session.Id,
                    OpponentName = enemy.HunterName,
                    Finished = true, 
                    Win = false, 
                    Log = log,
                    PlayerHp = 0,
                    EnemyHp = session.EnemyCurrentHp,
                    AvailableMoves = myMoves
                });
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
        public string MoveId { get; set; }
    }
}