using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DailyRpg.Data;
using DailyRpg.Models;
using System.Collections.Generic; // listas

namespace DailyRpg.ShopControllers
{
    [ApiController]
    [Route("api/[controller]")]

    public class ShopControllers : ControllerBase
    {
        private static readonly List<object> ShopItems = new List<object>
        {
            new {ItemId = "Heal", Name = "Poção de cura", Cost = 100, description = "Restaura todo o HP" },
            new {ItemId = "XPDouble", Name = "Poção de XP", Cost = 170, description = "Dobra o XP"}
        };

        private readonly ApiDbContext _context;

        public ShopControllers(ApiDbContext context)
        {
            _context = context;
        }
        [HttpGet("items")]
        public IActionResult GetShopitems()
        {
            return Ok(ShopItems);
        }

        [HttpPost("buy/{itemId}")]
        public async Task<IActionResult> BuyItem(string itemId)
        {
            var hunter = await _context.StatsUser.FirstOrDefaultAsync();
            if (hunter == null)
            {
                NotFound(new { Message = "User não encontrado" });
            }
            //Logica de comprar
            int ItemCost = 0;

            switch (itemId.ToLower())
            {
                case "heal":
                    ItemCost = 100;
                    if (hunter.CurrentCoins < ItemCost)
                    {
                        return BadRequest(new { Message = "Dinheiro Insuficinete" });
                    }
                    else
                    {
                        hunter.CurrentCoins -= ItemCost;
                        hunter.HealingPotions++;
                    }
                    
                    break;

                case "xpdoubler":
                    ItemCost = 150;
                    if (hunter.CurrentCoins < ItemCost)
                    {
                        BadRequest(new { Messsage = "Dinheiro Insufuciente" });
                    }
                    else
                    {
                        hunter.CurrentCoins -= ItemCost;
                        hunter.XpPotions++;
                    }
                    
                    break;
                default:
                    return NotFound(new { Message = "Item não esta disponível na loja" });
            }
            await _context.SaveChangesAsync();
            return Ok(hunter);
        }
    }
}