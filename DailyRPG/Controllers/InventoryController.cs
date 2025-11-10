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

        [HttpPost("use/{slotId}")]
        public async Task<IActionResult> UseItem(int slotId)
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

                var InventorySlot = await _context.InventorySlots.Include(c => c.Item).FirstOrDefaultAsync(s => s.Id == slotId && s.HunterUserId == hunterId);
                if (InventorySlot == null)
                {
                    return NotFound("Item não encontrado no seu inventário");
                }

                var item = InventorySlot.Item;

                string message = ""; //message para o flutter (=

                if (item.Type == ItemType.Consumable)
                {
                    hunter.CurrentHp += item.EffectValue;

                    if (hunter.CurrentHp > hunter.MaxHp)
                    {
                        hunter.CurrentHp = hunter.MaxHp;
                    }
                    message = $"Voce usou {item.Name} e restaurou {item.EffectValue} HP ";
                }
                else if (item.Type == ItemType.Xp)
                {
                    if (hunter.XpDouble == true)
                    {
                        BadRequest(new { Message = "Voce ja possui dobro de xp" });
                    }
                    else
                    {
                        hunter.XpDouble = true;
                        message = "Voce usou dobro de Xp";
                    }


                }
                else if (item.Type == ItemType.Equipament)
                {
                    if (item.EquipType == EquipmentType.Weapon)
                    {
                        hunter.Damage = item.EffectValue;
                        message = $"Você equipou {item.Name} (Dano: {item.EffectValue}).";

                    }
                    else if (item.EquipType == EquipmentType.Armor)
                    {
                        hunter.Defense = item.EffectValue;
                        message = $"Você equipou {item.Name} (Defesa: {item.EffectValue}).";
                    }
                }
                else
                {
                    return BadRequest($"{item.Name} não pode ser usado ou equipado.");
                }

                if (item.Type == ItemType.Consumable)
                {
                    InventorySlot.Quantity--;
                }
                if (item.Type == ItemType.Consumable && InventorySlot.Quantity <= 0)
                {
                    _context.InventorySlots.Remove(InventorySlot);
                }

                await _context.SaveChangesAsync();

                return Ok(new { message = message });
            } catch (Exception ex)
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