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

                var newContract = new Contract
                {
                    Id = 0,
                    Title = contractDto.Title,
                    Descricao = contractDto.Descricao,
                    Difficult = contractDto.Difficult,
                    XpReward = contractDto.XpReward,
                    CoinReward = contractDto.CoinReward,
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

        [HttpGet("fail")]
        public async Task<IActionResult> GetActiveContracts()
        {
            //Logica de Falha
            var today = DateTime.UtcNow;
            var hunter = await _context.StatsUser.FirstOrDefaultAsync();
            var failedContracts = await _context.Contracts.Where(c => !c.IsCompleted && c.StartDate < today).ToListAsync();
            bool hasFailed = false;
            if (hunter != null && failedContracts.Any())
            {
                foreach (var contract in failedContracts)
                {
                    hunter.CurrentHp -= 33;
                    contract.IsCompleted = true;
                    hasFailed = true;
                }
                await _context.SaveChangesAsync();
            }


            var contracts = await _context.Contracts.Where(c => !c.IsCompleted).OrderBy(c => c.StartDate).ToListAsync();

            return Ok(contracts);
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
                if (contract.Difficult == "Normal") { bonus = 2; }
                else if (contract.Difficult == "Hard") { bonus = 3; }

                if (hunter.XpDouble == true)
                {
                    totalXpGained += (contract.XpReward * bonus * 2);
                }
                else
                {
                    totalXpGained += (contract.XpReward * bonus);
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


                while (hunter.CurrentXp >= hunter.NextLevelXp)
                {
                    int xpNecessario = hunter.NextLevelXp; 
                    hunter.Level++; 
                    hunter.NextLevelXp += 200; 
                    
                  
                    hunter.CurrentXp -= xpNecessario; 
                    
                   
                    
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
            var contract = await _context.Contracts.FindAsync(id);

            if (contract == null)
            {
                return NotFound(new { message = "Contrato não encontrado." });
            }
            var hunter = await _context.StatsUser.FirstOrDefaultAsync();

            if (hunter == null)
            {
                return BadRequest(new { message = "Caçador não encontrado." });
            }
            int hpPenalty = 10;
            hunter.CurrentHp -= hpPenalty;
            if (hunter.CurrentHp < 0)
            {
                hunter.CurrentHp = 0;
            }
            _context.Contracts.Remove(contract);

            return Ok(new
            {
                message = "Contrato abandonado com sucesso.",
                penaltyApplied = hpPenalty
            });
        }
    }
}
