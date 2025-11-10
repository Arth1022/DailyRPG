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
    public class ShopControllers : ControllerBase
    {
        private readonly ApiDbContext _context;

        public ShopControllers(ApiDbContext context)
        {
            _context = context;
        }

        [HttpPost("buy/{itemId}")]
        public async Task<IActionResult> BuyItem(int itemId)
        {
            try
            {
                (var hunterId, var error) = _getUserClaims();
                if (error != null) return error;

                var hunter = await _context.StatsUser.FindAsync(hunterId);
                if (hunter == null)
                {
                    return NotFound("Caçador não encontrado.");
                }

                var itemToBuy = await _context.Items.FindAsync(itemId);
                if (itemToBuy == null)
                {
                    return NotFound("Item não encontrado na loja.");
                }

                if (hunter.CurrentCoins < itemToBuy.ShopPrice)
                {
                    return BadRequest("Ouro insuficiente.");
                }

                hunter.CurrentCoins -= itemToBuy.ShopPrice;


                var inventorySlot = await _context.InventorySlots
                    .FirstOrDefaultAsync(s => 
                        s.HunterUserId == hunterId && 
                        s.ItemId == itemId
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
                        ItemId = itemId,
                        Quantity = 1 
                    };
      
                    await _context.InventorySlots.AddAsync(newSlot);
                }

                await _context.SaveChangesAsync();

                return Ok(new { 
                    message = $"{itemToBuy.Name} comprado com sucesso!", 
                    newCoinTotal = hunter.CurrentCoins 
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Erro interno do servidor: {ex.Message}");
            }
        }


        private (int? hunterId, IActionResult? error) _getUserClaims()
        {
            var identity = HttpContext.User.Identity as ClaimsIdentity;
            if (identity == null)
            {
                return (null, Unauthorized("Token inválido (sem identidade)"));
            }

            var userClaim = identity.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier);
            if (userClaim == null)
            {
                return (null, Unauthorized("Token inválido (sem 'claim' de ID)"));
            }

            if (!int.TryParse(userClaim.Value, out int userId))
            {
                return (null, BadRequest("Token inválido (formato de ID)"));
            }

            return (userId, null);
        }
    }
}