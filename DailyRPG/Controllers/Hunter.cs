using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DailyRpg.Data;
using DailyRpg.Models;
using Microsoft.AspNetCore.Authorization;

namespace DailyRpg.HunterControllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
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
    }
}