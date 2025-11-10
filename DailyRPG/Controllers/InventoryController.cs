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
    public class InventoryController: ControllerBase
    {
        private readonly ApiDbContext _context;

        public InventoryController(ApiDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetInventory() 
        {
            try
            {
                (var hunterId, var error) = _getUserClaims();
                if (error != null) return error;

                var inventory = await _context.InventorySlots
                    .Where(s => s.HunterUserId == hunterId) 
                    .Include(s => s.Item)
                    .ToListAsync();

                return Ok(inventory);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Erro no servidor : {ex.Message}");
            }
        }

        private (int? hunterId, IActionResult? error) _getUserClaims()
        {
            var identity = HttpContext.User.Identity as ClaimsIdentity; 
            if (identity == null)
            {
                return (null, Unauthorized("Token inválido "));
            }

            var userClaim = identity.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier); 
            if (userClaim == null)
            {
                return (null, Unauthorized("Token invalido (sem claim de ID)"));
            }
            
            if (!int.TryParse(userClaim.Value, out int userId)) 
            {
                return (null, BadRequest("Token invalido (formato de ID)"));
            }
            
            return (userId, null); 
        }
    }
}