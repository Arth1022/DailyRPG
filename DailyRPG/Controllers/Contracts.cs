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

                // --- 1. VERIFICAÇÃO DE COOLDOWN (ANTI-FARM) ---
                // Verifica se já passaram 40 minutos desde o último contrato feito
                var lastCompleted = await _context.Contracts
                    .Where(c => c.HunterUserId == hunterId && c.IsCompleted && c.CompletedAt != null)
                    .OrderByDescending(c => c.CompletedAt)
                    .FirstOrDefaultAsync();

                if (lastCompleted != null)
                {
                    var timeDiff = DateTime.UtcNow - lastCompleted.CompletedAt.Value;
                    if (timeDiff.TotalMinutes < 40) 
                    {
                        int wait = 40 - (int)timeDiff.TotalMinutes;
                        return BadRequest(new { message = $"Você está exausto. Descanse por {wait} minutos." });
                    }
                }

                // Busca o contrato atual
                var contract = await _context.Contracts.FirstOrDefaultAsync(c => c.Id == id && c.HunterUserId == hunterId);
                
                if (contract == null || hunter == null) return NotFound(new { Message = "Contrato ou jogador não encontrado." });
                if (contract.IsCompleted) return BadRequest(new { Message = "Contrato já foi completo" });

                // --- 2. LÓGICA DE STREAK (COMBO DIÁRIO) ---
                var today = DateTime.UtcNow.Date;
                var lastActivity = hunter.LastActivityDate?.Date;

                if (lastActivity != null && lastActivity == today.AddDays(-1))
                {
                    hunter.CurrentStreak++; // Jogou ontem e hoje -> Aumenta
                }
                else if (lastActivity != null && lastActivity == today)
                {
                    // Jogou hoje de novo -> Mantém
                }
                else
                {
                    hunter.CurrentStreak = 1; // Quebrou o combo -> Reseta
                }
                
                hunter.LastActivityDate = DateTime.UtcNow; // Atualiza data da atividade

                // --- 3. CÁLCULO DE RECOMPENSAS ---
                contract.IsCompleted = true;
                contract.CompletedAt = DateTime.UtcNow; // Salva a hora da conclusão para o próximo cooldown

                // Bônus de Streak: +1% por dia (Max 50%)
                double streakBonus = 1.0 + (Math.Min(hunter.CurrentStreak, 50) / 100.0);
                
                // Base XP/Gold (Vem do contrato, definido na criação)
                int totalXpGained = (int)(contract.XpReward * streakBonus);
                int totalCoinsGained = (int)(contract.CoinReward * streakBonus);

                // Bônus de Buff (Poção de XP)
                if (hunter.XpDouble == true)
                {
                    totalXpGained *= 2;
                    hunter.XpDouble = false; // Consome o buff
                }

                string streakMsg = hunter.CurrentStreak > 1 ? $" 🔥 Streak {hunter.CurrentStreak} (+{(int)((streakBonus - 1)*100)}%)!" : "";

                // --- 4. LÓGICA DO CHEFE (BOSS) ---
                string bossMessage = "";
                
                if (hunter.CurrentBossId != null && hunter.CurrentBoss != null)
                {
                    var bossTemplate = hunter.CurrentBoss;
                    hunter.CurrentBossHp -= hunter.Damage;
                    bossMessage = $" -{hunter.Damage} HP no Chefe!";

                    if (hunter.CurrentBossHp <= 0)
                    {
                        bossMessage += " (DERROTADO!)";
                        totalXpGained += bossTemplate.RewardXp;
                        totalCoinsGained += bossTemplate.RewardCoin;

                        // Passa para o próximo chefe
                        if (bossTemplate.NextBossId != null)
                        {
                            var nextBoss = await _context.Bosses.FindAsync(bossTemplate.NextBossId);
                            if (nextBoss != null)
                            {
                                hunter.CurrentBossId = nextBoss.Id;
                                hunter.CurrentBossHp = nextBoss.MaxHp;
                                bossMessage += $" Novo chefe: {nextBoss.Name}!";
                            }
                            else hunter.CurrentBossId = null;
                        }
                        else hunter.CurrentBossId = null; 
                    }
                } 

                // Aplica os ganhos finais ao jogador
                hunter.CurrentXp += totalXpGained;
                hunter.CurrentCoins += totalCoinsGained;

                // --- 5. LEVEL UP ---
                if (hunter.CurrentXp >= hunter.NextLevelXp)
                {
                    hunter.Level++; 
                    hunter.CurrentXp -= hunter.NextLevelXp; 
                    hunter.NextLevelXp = (int)(hunter.NextLevelXp * 1.5); // Curva de XP (Aumenta 50% a cada nível)
                    hunter.CurrentHp = hunter.MaxHp; // Cura total ao upar
                    hunter.AttributePoints += 3; // Ganha pontos para distribuir
                }

                // --- 6. DROP DE ITENS (50% Chance) ---
                string dropMessage = "";
                int dropChance = 50; 
                if (_random.Next(100) < dropChance)
                {
                    var materialDrops = await _context.Items.Where(i => i.Type == ItemType.Material).ToListAsync();
                    if (materialDrops.Any())
                    {
                        var itemToDrop = materialDrops[_random.Next(materialDrops.Count)];
                        
                        var inventorySlot = await _context.InventorySlots
                            .FirstOrDefaultAsync(s => s.HunterUserId == hunterId && s.ItemId == itemToDrop.Id);

                        if (inventorySlot != null) inventorySlot.Quantity++;
                        else await _context.InventorySlots.AddAsync(new InventorySlot { HunterUserId = hunterId.Value, ItemId = itemToDrop.Id, Quantity = 1 });
                        
                        dropMessage = $" +1 {itemToDrop.Name}!";
                    }
                }

                await _context.SaveChangesAsync();

                return Ok(new { 
                    message = $"Sucesso! {streakMsg}{dropMessage}{bossMessage}", 
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

       private static readonly List<ContractBoardItem> _dailyTasksPool = new List<ContractBoardItem>
        {
            // ==================================================
            // FÁCIL (Tarefas rápidas, < 15 min, "Momentum")
            // ==================================================
            // Casa
            new ContractBoardItem { Title = "Lavar a Louça", Description = "A pia não é lugar de monstros. Deixe-a limpa.", Difficulty = "easy" },
            new ContractBoardItem { Title = "Arrumar a Cama", Description = "Comece o dia com ordem no caos.", Difficulty = "easy" },
            new ContractBoardItem { Title = "Tirar o Lixo", Description = "Remova os resíduos tóxicos da sua base.", Difficulty = "easy" },
            new ContractBoardItem { Title = "Regar as Plantas", Description = "Cuide da flora local.", Difficulty = "easy" },
            new ContractBoardItem { Title = "Varrer um Cômodo", Description = "Elimine a poeira de uma área específica.", Difficulty = "easy" },
            new ContractBoardItem { Title = "Limpar Micro-ondas", Description = "Remova as manchas de explosões passadas.", Difficulty = "easy" },
            new ContractBoardItem { Title = "Abrir as Janelas", Description = "Renove o ar do seu santuário.", Difficulty = "easy" },
            
            // Saúde / Pessoal
            new ContractBoardItem { Title = "Beber 2 Copos d'Água", Description = "Poção de Hidratação Instantânea.", Difficulty = "easy" },
            new ContractBoardItem { Title = "Alongamento (5 min)", Description = "Remova o debuff de 'Rigidez'.", Difficulty = "easy" },
            new ContractBoardItem { Title = "Tomar Vitaminas", Description = "Buff diário de imunidade.", Difficulty = "easy" },
            new ContractBoardItem { Title = "Passar Fio Dental", Description = "Higiene avançada necessária.", Difficulty = "easy" },
            new ContractBoardItem { Title = "Lavar o Rosto", Description = "Água fria para despertar o espírito.", Difficulty = "easy" },
            
            // Digital / Mental
            new ContractBoardItem { Title = "Limpar Caixa de Email", Description = "Delete 10 emails inúteis (Spam).", Difficulty = "easy" },
            new ContractBoardItem { Title = "Ler 5 Páginas", Description = "Um pouco de conhecimento não faz mal.", Difficulty = "easy" },
            new ContractBoardItem { Title = "Elogiar Alguém", Description = "Aumente seu Carisma com uma boa ação.", Difficulty = "easy" },
            new ContractBoardItem { Title = "Meditar (5 min)", Description = "Acalme a mente e recupere Mana.", Difficulty = "easy" },

            // ==================================================
            // MÉDIO (Esforço moderado, 30-60 min)
            // ==================================================
            // Casa
            new ContractBoardItem { Title = "Lavar Roupa", Description = "Separe, lave e estenda a armadura suja.", Difficulty = "medium" },
            new ContractBoardItem { Title = "Cozinhar Refeição", Description = "Crafting de comida saudável (+Vitalidade).", Difficulty = "medium" },
            new ContractBoardItem { Title = "Limpar Banheiro", Description = "Uma tarefa suja, mas essencial.", Difficulty = "medium" },
            new ContractBoardItem { Title = "Trocar Lençóis", Description = "Roupa de cama limpa melhora o descanso.", Difficulty = "medium" },
            new ContractBoardItem { Title = "Organizar Mesa", Description = "Melhore seu ambiente de trabalho.", Difficulty = "medium" },
            
            // Saúde / Fitness
            new ContractBoardItem { Title = "Treino de Força", Description = "Puxar ferro ou calistenia. +Força.", Difficulty = "medium" },
            new ContractBoardItem { Title = "Caminhada (30 min)", Description = "Patrulha diária pelo bairro.", Difficulty = "medium" },
            new ContractBoardItem { Title = "Sem Açúcar Hoje", Description = "Resista à tentação dos doces por 24h.", Difficulty = "medium" },
            new ContractBoardItem { Title = "Comer Fruta e Legume", Description = "Nutrição balanceada é a chave.", Difficulty = "medium" },
            
            // Produtividade
            new ContractBoardItem { Title = "Estudar (40 min)", Description = "Foco total. Desligue as notificações.", Difficulty = "medium" },
            new ContractBoardItem { Title = "Ler 20 Páginas", Description = "Aprofunde-se na história ou estudo.", Difficulty = "medium" },
            new ContractBoardItem { Title = "Revisar Finanças", Description = "Verifique seu saldo e gastos do dia.", Difficulty = "medium" },
            new ContractBoardItem { Title = "Pagar Contas", Description = "Evite os juros do cobrador de impostos.", Difficulty = "medium" },
            new ContractBoardItem { Title = "Ligar para Família", Description = "Mantenha os laços com seu clã fortes.", Difficulty = "medium" },

            // ==================================================
            // DIFÍCIL (Desafiador, requer força de vontade)
            // ==================================================
            // Físico
            new ContractBoardItem { Title = "Corrida de 5km", Description = "Teste de resistência (Endurance).", Difficulty = "hard" },
            new ContractBoardItem { Title = "Treino Intenso (1h)", Description = "Sair da zona de conforto.", Difficulty = "hard" },
            new ContractBoardItem { Title = "Banho Gelado", Description = "Resistência ao frio e disciplina mental.", Difficulty = "hard" },
            
            // Casa / Organização
            new ContractBoardItem { Title = "Faxina Pesada", Description = "Limpar janelas, chão e móveis.", Difficulty = "hard" },
            new ContractBoardItem { Title = "Organizar Guarda-Roupa", Description = "Doe o que não usa. Organize o resto.", Difficulty = "hard" },
            new ContractBoardItem { Title = "Consertar Algo", Description = "Aquele item quebrado há meses. Arrume hoje.", Difficulty = "hard" },
            
            // Intelectual
            new ContractBoardItem { Title = "Estudar 2 Horas", Description = "Sessão 'Deep Work' sem distrações.", Difficulty = "hard" },
            new ContractBoardItem { Title = "Ler 50 Páginas", Description = "Imersão total no conhecimento.", Difficulty = "hard" },
            new ContractBoardItem { Title = "Escrever/Criar", Description = "Produza algo (texto, código, arte) por 1h.", Difficulty = "hard" },

            // ==================================================
            // LENDÁRIO (Épico, muda a vida se feito sempre)
            // ==================================================
            new ContractBoardItem { Title = "Detox Digital 24h", Description = "Nenhuma rede social por um dia inteiro.", Difficulty = "legendary" },
            new ContractBoardItem { Title = "Zerar as Pendências", Description = "Resolva TODAS as tarefas atrasadas da lista.", Difficulty = "legendary" },
            new ContractBoardItem { Title = "Terminar um Livro", Description = "Ler os últimos capítulos e finalizar.", Difficulty = "legendary" },
            new ContractBoardItem { Title = "Acordar às 5h", Description = "Veja o sol nascer e domine o dia.", Difficulty = "legendary" },
            new ContractBoardItem { Title = "Corrida de 10km", Description = "Apenas para os verdadeiros guerreiros.", Difficulty = "legendary" },
            new ContractBoardItem { Title = "Jejum de 16h", Description = "Disciplina alimentar suprema (com cuidado).", Difficulty = "legendary" }
        };

        [HttpGet("board")]
        public async Task<IActionResult> GetGuildBoard()
        {
            // 1. Identificar o Usuário
            (var hunterId, var error) = _getUserClaims();
            if (error != null) return error;

            // 2. Gerar a Semente do Dia (Seed)
            int seed = DateTime.UtcNow.Year * 10000 + DateTime.UtcNow.Month * 100 + DateTime.UtcNow.Day;
            var randomDaily = new Random(seed);

            // 3. Preparar as listas (Igual fizemos antes)
            var easyTasks = Shuffle(_dailyTasksPool.Where(t => t.Difficulty == "easy").ToList(), randomDaily);
            var mediumTasks = Shuffle(_dailyTasksPool.Where(t => t.Difficulty == "medium").ToList(), randomDaily);
            var hardTasks = Shuffle(_dailyTasksPool.Where(t => t.Difficulty == "hard").ToList(), randomDaily);
            var legTasks = Shuffle(_dailyTasksPool.Where(t => t.Difficulty == "legendary").ToList(), randomDaily);

            // 4. Montar o Quadro Base (3 Fáceis, 2 Médios, 1 Difícil/Lendário)
            var boardOfTheDay = new List<ContractBoardItem>();
            boardOfTheDay.AddRange(easyTasks.Take(3));
            boardOfTheDay.AddRange(mediumTasks.Take(2));

            if (randomDaily.Next(100) < 10 && legTasks.Any()) 
                boardOfTheDay.Add(legTasks.First()); 
            else 
                boardOfTheDay.Add(hardTasks.First());
            
           
            var today = DateTime.UtcNow.Date;
            
            var existingContracts = await _context.Contracts
                .Where(c => c.HunterUserId == hunterId && 
                           (!c.IsCompleted || (c.IsCompleted && c.CompletedAt >= today)))
                .Select(c => c.Title) // Pegamos só os títulos para comparar
                .ToListAsync();

            boardOfTheDay.RemoveAll(item => existingContracts.Contains(item.Title));

            return Ok(boardOfTheDay);
        }

        // Função auxiliar para embaralhar lista de forma determinística (com Seed)
        private List<T> Shuffle<T>(List<T> list, Random rng)
        {
            var shuffled = new List<T>(list);
            int n = shuffled.Count;
            while (n > 1)
            {
                n--;
                int k = rng.Next(n + 1);
                T value = shuffled[k];
                shuffled[k] = shuffled[n];
                shuffled[n] = value;
            }
            return shuffled;
        }

        // DTO (Se já não tiver no arquivo)
        public class ContractBoardItem
        {
            public string Title { get; set; }
            public string Description { get; set; }
            public string Difficulty { get; set; }
        }
    }
}
