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
    public class InventoryController : ControllerBase
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
                return StatusCode(500, $"Erro interno: {ex.Message}");
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
                
                var slot = await _context.InventorySlots
                    .Include(s => s.Item) 
                    .FirstOrDefaultAsync(s => 
                        s.Id == slotId && 
                        s.HunterUserId == hunterId
                    );

                if (hunter == null || slot == null)
                {
                    return NotFound("Caçador ou item não encontrado.");
                }

                var item = slot.Item;
                string message = "";

                switch (item.Type)
                {
                    case ItemType.Consumable:
                        hunter.CurrentHp += item.EffectValue;
                        if (hunter.CurrentHp > hunter.MaxHp)
                        {
                            hunter.CurrentHp = hunter.MaxHp;
                        }
                        
                        slot.Quantity--;
                        if (slot.Quantity <= 0)
                        {
                            _context.InventorySlots.Remove(slot);
                        }
                        message = $"Você usou {item.Name} e curou {item.EffectValue} HP.";
                        break;

                    case ItemType.Equipament:
                        if (item.EquipType == EquipmentType.Weapon)
                        {
                            if (hunter.EquippedWeaponSlotId == slot.Id)
                            {
                                hunter.EquippedWeaponSlotId = null; 
                                message = $"Você desequipou {item.Name}.";
                            }
                            else
                            {
                                hunter.EquippedWeaponSlotId = slot.Id;
                                message = $"Você equipou {item.Name}.";
                            }
                        }
                        else if (item.EquipType == EquipmentType.Armor)
                        {
                            if (hunter.EquippedArmorSlotId == slot.Id)
                            {
                                hunter.EquippedArmorSlotId = null;
                                message = $"Você desequipou {item.Name}.";
                            }
                            else
                            {
                                hunter.EquippedArmorSlotId = slot.Id;
                                message = $"Você equipou {item.Name}.";
                            }
                        }
                        break;
                    case ItemType.Xp:
                        if (hunter.XpDouble == false){
                            hunter.XpDouble = true;
                            if (hunter.CurrentHp > hunter.MaxHp)
                            {
                                hunter.CurrentHp = hunter.MaxHp;
                            }
                            
                            slot.Quantity--;
                            if (slot.Quantity <= 0)
                            {
                                _context.InventorySlots.Remove(slot);
                            }
                            message = $"Você usou {item.Name} e dobrou seu XP por um contrato.";
                        }
                        else
                        {
                            message = $"Você já esta dobrado!";
                        }
                        break;
                }

                await RecalculateStats(hunter);

                await _context.SaveChangesAsync();

                return Ok(new { message = message, hunter = hunter });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Erro interno: {ex.Message}");
            }
        }

        private async Task RecalculateStats(HunterUser hunter)
        {

            Item? equippedWeapon = null;
            if (hunter.EquippedWeaponSlotId != null)
            {
                var weaponSlot = await _context.InventorySlots
                    .Include(s => s.Item) 
                    .FirstOrDefaultAsync(s => s.Id == hunter.EquippedWeaponSlotId);
                if (weaponSlot != null) equippedWeapon = weaponSlot.Item;
            }

            Item? equippedArmor = null;
            if (hunter.EquippedArmorSlotId != null)
            {
                var armorSlot = await _context.InventorySlots
                    .Include(s => s.Item) 
                    .FirstOrDefaultAsync(s => s.Id == hunter.EquippedArmorSlotId);
                if (armorSlot != null) equippedArmor = armorSlot.Item;
            }

      
            int oldMaxHp = hunter.MaxHp;
            hunter.MaxHp = 100 + (hunter.Constitution * 10);

            if (hunter.CurrentHp != oldMaxHp && hunter.CurrentHp < hunter.MaxHp)
            {
                hunter.CurrentHp += (hunter.MaxHp - oldMaxHp);
                if (hunter.CurrentHp > hunter.MaxHp) hunter.CurrentHp = hunter.MaxHp;
            }
 
            if (hunter.CurrentHp > hunter.MaxHp)
            {
                hunter.CurrentHp = hunter.MaxHp;
            }

            hunter.Defense = hunter.Endurance;
            if (equippedArmor != null)
            {
                hunter.Defense += equippedArmor.EffectValue; 
            }

            hunter.Damage = hunter.Strength; 

            if (equippedWeapon != null)
            {
                hunter.Damage = equippedWeapon.EffectValue;

                if (equippedWeapon.SkillAffinity == "Strength")
                {
                    hunter.Damage += hunter.Strength;
                }
                else if (equippedWeapon.SkillAffinity == "Dexterity")
                {
                    hunter.Damage += hunter.Dexterity;
                }
                else if (equippedWeapon.SkillAffinity == "Intelligence")
                {
                    hunter.Damage += hunter.Intelligence;
                }

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