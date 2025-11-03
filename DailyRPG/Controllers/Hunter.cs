using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DailyRpg.Data;
using DailyRpg.Models;

namespace DailyRpg.HunterControllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HunterControllers : ControllerBase
    {
        private readonly ApiDbContext _context;

        public HunterControllers(ApiDbContext context)
        {
            _context = context;
        }

        [HttpGet("stats")]
        public async Task<IActionResult> GetHunterStats()
        {
            var hunter = await _context.StatsUser.FirstOrDefaultAsync();

            if (hunter == null)
            {
                hunter = new HunterUser();
                _context.StatsUser.Add(hunter);
                await _context.SaveChangesAsync();
            }
            return Ok(hunter);
        }

        [HttpPost("use/Heal")]
        public async Task<IActionResult> UsePotion()
        {
            var hunter = await _context.StatsUser.FirstOrDefaultAsync();
            if (hunter == null)
            {
                NotFound(new { Message = "User não encontrado" });
            }
            if (hunter.HealingPotions == 0)
            {
                BadRequest(new { Message = "User não contem esta poção" });

            }
            if (hunter.CurrentHp == 100)
            {
                BadRequest(new { Message = "Hp está no maximo" });
            }
            hunter.HealingPotions--;
            hunter.MaxHp = hunter.MaxHp;

            await _context.SaveChangesAsync();
            return Ok(hunter);
        }
        [HttpPost("use/XpPotion")]
        public async Task<IActionResult> UseXpPotion()
        {
            var hunter = await _context.StatsUser.FirstOrDefaultAsync();
            if (hunter == null)
            {
                NotFound(new { Message = "User não foi encontrado" });
            }
            if (hunter.XpPotions == 0)
            {
                BadRequest(new { Message = "Poções insuficientes" });
            }
            hunter.XpDouble = true;
            hunter.XpPotions--;

            await _context.SaveChangesAsync();
            return Ok(hunter);
        }
    }
}