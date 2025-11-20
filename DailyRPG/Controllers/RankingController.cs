using DailyRpg.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace DailyRpg.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class RankingController : ControllerBase
    {
        private readonly ApiDbContext _context;

        public RankingController(ApiDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetTop100()
        {
            var topHunters = await _context.StatsUser
                .AsNoTracking()
                .OrderByDescending(u => u.Level)
                .ThenByDescending(u => u.CurrentXp)
                .Take(100) 
                .Select(u => new RankingDto
                {
                    HunterName = u.HunterName,
                    Level = u.Level,
                   
                })
                .ToListAsync();

            return Ok(topHunters);
        }
    }

  
    public class RankingDto
    {
        public string HunterName { get; set; }
        public int Level { get; set; }
    }
}
