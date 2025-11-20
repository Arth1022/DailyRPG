using DailyRpg.Data;
using DailyRpg.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace DailyRpg.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ContractsControllers : ControllerBase
    {
        private readonly ApiDbContext _context;

        private static readonly Random _random = new Random();

        public ContractsControllers(ApiDbContext context)
        {
            _context = context;
        }

   
        [HttpPost]
        public async Task<IActionResult> CreateContract([FromBody] CreateContractDto contractDto)
        {
            try
            {
                (var hunterId, var error) = _getUserClaims();
                if (error != null) return error;

                // COOLDOWN DE CRIAÇÃO (5 Minutos) ---
                var lastCreated = await _context.Contracts
                    .Where(c => c.HunterUserId == hunterId)
                    .OrderByDescending(c => c.StartDate)
                    .FirstOrDefaultAsync();

                if (lastCreated != null)
                {
                    var timeDiff = DateTime.UtcNow - lastCreated.StartDate;
                    if (timeDiff.TotalMinutes < 5) // 5 Minutos para criar
                    {
                        int wait = 5 - (int)timeDiff.TotalMinutes;
                        return BadRequest(new { message = $"A Guilda está ocupada. Aguarde {wait} minutos para solicitar um novo contrato." });
                    }
                }

                // LIMITE DE SLOTS POR DIFICULDADE ---
                string difficulty = contractDto.Difficulty?.ToLower() ?? "medium";
                
                // Conta quantos contratos ATIVOS (não completados) existem dessa dificuldade
                int activeCount = await _context.Contracts
                    .CountAsync(c => c.HunterUserId == hunterId && !c.IsCompleted && c.Difficulty == difficulty);

                int maxAllowed = 0;
                int xp = 0; 
                int coin = 0;

                switch (difficulty)
                {
                    case "easy":      maxAllowed = 3; xp = 50;  coin = 15;  break;
                    case "medium":    maxAllowed = 2; xp = 100; coin = 40;  break;
                    case "hard":      maxAllowed = 1; xp = 300; coin = 100; break;
                    case "legendary": maxAllowed = 1; xp = 800; coin = 300; break;
                    default:          maxAllowed = 2; xp = 100; coin = 40;  break;
                }

                if (activeCount >= maxAllowed)
                {
                    return BadRequest(new { message = $"Limite de contratos '{difficulty}' atingido ({activeCount}/{maxAllowed}). Conclua ou desista de um antes de criar outro." });
                }

                // --- CRIAÇÃO ---
                var newContract = new Contract
                {
                    Title = contractDto.Title,
                    Descricao = contractDto.Descricao,
                    Difficulty = difficulty,
                    XpReward = xp,
                    CoinReward = coin,
                    StartDate = DateTime.UtcNow,
                    IsCompleted = false,
                    HunterUserId = hunterId.Value
                };

                await _context.Contracts.AddAsync(newContract);
                await _context.SaveChangesAsync();
                
                return Ok(newContract); 
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Erro interno: {ex.Message}");
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetContractById(int id)
        {
            var contract = await _context.Contracts.FindAsync(id);

            if (contract == null)
            {
                return NotFound();
            }
            return Ok(contract);
        }

        [HttpPut("{id}/complete")]
        public async Task<IActionResult> CompleteContract(int id)
        {
            try
            {
                (var hunterId, var error) = _getUserClaims();
                if (error != null) return error;

                var hunter = await _context.StatsUser
                    .Include(h => h.CurrentBoss)
                    .FirstOrDefaultAsync(h => h.Id == hunterId);
                
                var contract = await _context.Contracts.FirstOrDefaultAsync(c => c.Id == id && c.HunterUserId == hunterId);
                            
                if (contract == null || hunter == null)
                {
                    return NotFound(new { Message = "Contrato ou jogador não encontrado." });
                }
                if (contract.IsCompleted)
                {
                    return BadRequest(new { Message = "Contrato ja foi completo" });
                }
                
                contract.IsCompleted = true;
     
                int totalXpGained = 0;
                int totalCoinsGained = contract.CoinReward; 
                string bossMessage = "";
                string dropMessage = "";

                int bonus = 1;
                if (contract.Difficulty == "Normal") { bonus = 2; }
                else if (contract.Difficulty == "Hard") { bonus = 3; }

                if (hunter.XpDouble == true)
                {
                    totalXpGained += contract.XpReward * bonus * 2;
                }
                else
                {
                    totalXpGained += contract.XpReward * bonus;
                }
                hunter.XpDouble = false; 


           
                if (hunter.CurrentBossId != null && hunter.CurrentBoss != null)
                {
                    var bossTemplate = hunter.CurrentBoss;
                    hunter.CurrentBossHp -= hunter.Damage;
                    
                    bossMessage = $" Você causou {hunter.Damage} de dano ao {bossTemplate.Name}!";

                    if (hunter.CurrentBossHp <= 0)
                    {
                        bossMessage += $" (DERROTADO!)";
                        
                        totalXpGained += bossTemplate.RewardXp;
                        totalCoinsGained += bossTemplate.RewardCoin;

                        if (bossTemplate.NextBossId != null)
                        {
                            var nextBoss = await _context.Bosses.FindAsync(bossTemplate.NextBossId);
                            if (nextBoss != null)
                            {
                                hunter.CurrentBossId = nextBoss.Id;
                                hunter.CurrentBossHp = nextBoss.MaxHp;
                                bossMessage += $" O {nextBoss.Name} (Nv. {nextBoss.Level}) apareceu!";
                            }
                            else
                            {
                                hunter.CurrentBossId = null;
                            }
                        }
                        else
                        {
                            hunter.CurrentBossId = null; 
                        }
                    }
                } 

            
                hunter.CurrentXp += totalXpGained;
                hunter.CurrentCoins += totalCoinsGained;


                if (hunter.CurrentXp >= hunter.NextLevelXp)
                {
                    hunter.Level++; 
                    
                    int xpToLevelUp = hunter.NextLevelXp;

                    hunter.CurrentXp -= xpToLevelUp; 
                    hunter.NextLevelXp += 200; 
                   
                    
                    hunter.CurrentHp = 100;
                    hunter.AttributePoints += 1;
                }

        
                int dropChance = 50; 
                if (_random.Next(100) < dropChance)
                {
                    var materialDrops = await _context.Items
                        .Where(i => i.Type == ItemType.Material) 
                        .ToListAsync();

                    if (materialDrops.Any())
                    {
                        var itemToDrop = materialDrops[_random.Next(materialDrops.Count)];

                        var inventorySlot = await _context.InventorySlots
                            .FirstOrDefaultAsync(s => 
                                s.HunterUserId == hunterId && 
                                s.ItemId == itemToDrop.Id
                            );

                        if (inventorySlot != null)
                        {
                            inventorySlot.Quantity++;
                        }
                        else
                        {
                            var newSlot = new InventorySlot
                            {
                                HunterUserId = hunterId.Value,
                                ItemId = itemToDrop.Id,
                                Quantity = 1
                            };
                            await _context.InventorySlots.AddAsync(newSlot);
                        }
                        
                        dropMessage = $" Você também obteve 1x {itemToDrop.Name}!";
                    }
                }
                
                

                await _context.SaveChangesAsync();

                return Ok(new { 
                    message = $"Contrato concluído!{dropMessage}{bossMessage}", 
                    updatedHunter = hunter 
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Erro interno: {ex.Message}");
            }
        }
        private (int? hunterId, IActionResult? error) _getUserClaims()
        {
            var identity = HttpContext.User.Identity as ClaimsIdentity;
            if (identity == null) 
            {
                return (null, Unauthorized("Token inválido"));
            }
            
            var userClaim = identity.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier);
            if (userClaim == null) 
            {
                return (null, Unauthorized("Token inválido (sem claim)"));
            }

            if (!int.TryParse(userClaim.Value, out int userId)) 
            {
                return (null, BadRequest("Token inválido (formato de ID)"));
            }
            
            return (userId, null);
        }

        [HttpGet("undone")]
        public async Task<IActionResult> UndoneContracts()
        {
            var contrato = await _context.Contracts.Where(c => !c.IsCompleted).ToListAsync();
            if (contrato == null)
            {
                return NotFound();
            }
            return Ok(contrato);
        }
        [HttpPost("abandon/{id}")]
        public async Task<IActionResult> AbandonContract(int id)
        {
            (var hunterId, var error) = _getUserClaims();
            if (error != null) return error;

            var contract = await _context.Contracts.FirstOrDefaultAsync(c => c.Id == id && c.HunterUserId == hunterId);

            if (contract == null)
            {
                return NotFound(new { message = "Contrato não encontrado." });
            }

            var hunter = await _context.StatsUser.FindAsync(hunterId);

            if (hunter == null)
            {
                return BadRequest(new { message = "Caçador não encontrado." });
            }

            int hpPenalty = 0;
            string difficulty = contract.Difficulty?.ToLower() ?? "medium";

            switch (difficulty)
            {
                case "easy":
                    hpPenalty = 5;
                    break;
                case "hard":
                    hpPenalty = 25; 
                    break;
                case "legendary":
                    hpPenalty = 60; // Penalidade severa
                    break;
                case "medium":
                default:
                    hpPenalty = 10;
                    break;
            }

            hunter.CurrentHp -= hpPenalty;
            if (hunter.CurrentHp < 0)
            {
                hunter.CurrentHp = 0;
            }

            _context.Contracts.Remove(contract);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = $"Contrato abandonado. Você sofreu {hpPenalty} de dano pela quebra de juramento.",
                penaltyApplied = hpPenalty,
                remainingHp = hunter.CurrentHp
            });
        }
    }
}
