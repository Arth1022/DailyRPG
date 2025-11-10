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

                var inventorySlot = await _context.InventorySlots
                    .Include(s => s.Item) 
                    .FirstOrDefaultAsync(s => 
                        s.Id == slotId && 
                        s.HunterUserId == hunterId
                    );

                if (inventorySlot == null)
                {
                    return NotFound("Item não encontrado no seu inventário.");
                }

                var item = inventorySlot.Item;
                string message = "";


                if (item.Type == ItemType.Consumable)
                {
                    hunter.CurrentHp += item.EffectValue;
                    if (hunter.CurrentHp > hunter.MaxHp)
                    {
                        hunter.CurrentHp = hunter.MaxHp;
                    }
                    message = $"Você usou {item.Name} e restaurou {item.EffectValue} HP.";


                    inventorySlot.Quantity--;
                    if (inventorySlot.Quantity <= 0)
                    {
                        _context.InventorySlots.Remove(inventorySlot);
                    }
                }

                else if (item.Type == ItemType.Equipament)
                {
                    if (item.EquipType == EquipmentType.Weapon)
                    {
                        // É uma Arma
                        if (hunter.EquippedWeaponSlotId == slotId)
                        {
                            
                            hunter.Damage = 1; 
                            hunter.EquippedWeaponSlotId = null; 
                            message = $"Você desequipou {item.Name}.";
                        }
                        else
                        {
                 
                            hunter.Damage = item.EffectValue;
                            hunter.EquippedWeaponSlotId = slotId;
                            message = $"Você equipou {item.Name} (Dano: {item.EffectValue}).";
                        }
                    }
                    else if (item.EquipType == EquipmentType.Armor)
                    {
                 
                        if (hunter.EquippedArmorslotId  == slotId)
                        {

                            hunter.Defense = 0; 
                            hunter.EquippedArmorslotId = null;
                            message = $"Você desequipou {item.Name}.";
                        }
                        else
                        {
                   
                            hunter.Defense = item.EffectValue;
                            hunter.EquippedArmorslotId  = slotId;
                            message = $"Você equipou {item.Name} (Defesa: {item.EffectValue}).";
                        }
                    }
                }
                else
                {
                    return BadRequest($"{item.Name} não pode ser usado.");
                }

                // Passo 5: Salvar TUDO
                await _context.SaveChangesAsync();

                return Ok(new { message = message });
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