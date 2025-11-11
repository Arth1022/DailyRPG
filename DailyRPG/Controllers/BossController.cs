using DailyRpg.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace DailyRpg.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize] 
    public class BossController : ControllerBase
    {
        private readonly ApiDbContext _context;

        public BossController(ApiDbContext context)
        {
            _context = context;
        }


        [HttpGet]
        public async Task<IActionResult> GetCurrentBossStatus()
        {
            try
            {
                (var hunterId, var error) = _getUserClaims();
                if (error != null) return error;

                var hunter = await _context.StatsUser
                    .Include(h => h.CurrentBoss) 
                    .FirstOrDefaultAsync(h => h.Id == hunterId);

                if (hunter == null)
                {
                    return NotFound("Caçador não encontrado.");
                }

                if (hunter.CurrentBoss == null)
                {
                    return Ok(new { message = "Você derrotou todos os chefes!" });
                }

                var bossStatus = new {
                    BossName = hunter.CurrentBoss.Name,
                    BossLevel = hunter.CurrentBoss.Level,
                    CurrentHp = hunter.CurrentBossHp, 
                    MaxHp = hunter.CurrentBoss.MaxHp 
                };

                return Ok(bossStatus);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Erro interno: {ex.Message}");
            }
        }


        private (int? hunterId, IActionResult? error) _getUserClaims()
        {
            var identity = HttpContext.User.Identity as ClaimsIdentity;
            if (identity == null) return (null, Unauthorized("Token inválido"));
            var userClaim = identity.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier);
            if (userClaim == null) return (null, Unauthorized("Token inválido (sem claim)"));
            if (!int.TryParse(userClaim.Value, out int userId)) return (null, BadRequest("Token inválido (formato de ID)"));
            return (userId, null);
        }
    }
}