using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DailyRpg.Data;
using DailyRpg.Models;

namespace DailyRpg.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ContractsControllers : ControllerBase
    {
        private readonly ApiDbContext _context;

        public ContractsControllers(ApiDbContext context)
        {
            _context = context;
        }

        //End_Points

        [HttpPost]
        public async Task<IActionResult> CreateContract([FromBody] Contract newContract)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }
            await _context.Contracts.AddAsync(newContract);

            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetContractById), new { id = newContract.Id }, newContract); //Retorna qual objeto foi criado
        }

        [HttpGet("fail")] // /api/contracts/active
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
            var contract = await _context.Contracts.FindAsync(id);
            if (contract == null)
            {
                return NotFound(new { Message = "Contrato não encontrado." });
            }
            if (contract.IsCompleted)
            {
                return BadRequest(new { Message = "Contrato ja foi completo" });
            }

            var hunter = await _context.StatsUser.FirstOrDefaultAsync();
            if (hunter == null)
            {
                return NotFound(new { Message = "User não foi encontrado." });
            }
            //Logica do jogo

            contract.IsCompleted = true;
            int bonus = 1;
            if (contract.Difficult == "Normal") { bonus = 2; }

            else if (contract.Difficult == "Hard") { bonus = 3; }

            if (hunter.XpDouble == true)
            {
                hunter.CurrentXp = hunter.CurrentXp + (contract.XpReward * bonus * 2);
            }
            else
            {
                hunter.CurrentXp = hunter.CurrentXp + (contract.XpReward * bonus);
            }
            hunter.XpDouble = false;

            if (hunter.CurrentXp >= hunter.NextLevelXp)
            {
                hunter.Level++; //Sobe o level
                hunter.NextLevelXp += 200; //Aumenta a qtd para o proximo nivel
                hunter.CurrentXp -= hunter.NextLevelXp; //zera e deixa o restante 
                hunter.CurrentHp = 100; //vida maxima!
            }
            hunter.CurrentCoins = contract.CoinReward;

            await _context.SaveChangesAsync();

            return Ok(hunter);

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
