using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DailyRpg.Data;
using DailyRpg.Models;
using Microsoft.VisualBasic;
using System.Reflection.Metadata.Ecma335;
using Microsoft.AspNetCore.Http.HttpResults;

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

        [HttpGet("active")] // /api/contracts/active
        public async Task<IActionResult> GetActiveContracts()
        {
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
    }
}
