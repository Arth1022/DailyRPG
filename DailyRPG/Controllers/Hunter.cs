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
    public class HunterController : ControllerBase
    {
        private readonly ApiDbContext _context;

        public HunterController(ApiDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetHunterStats()
        {
            try
            {
                (var hunterId, var error) = _getUserClaims();
                if (error != null) return error;

                var hunter = await _context.StatsUser
                    .Include(h => h.EquippedWeaponSlot)
                        .ThenInclude(s => s!.Item)
                    .Include(h => h.EquippedArmorSlot)
                        .ThenInclude(s => s!.Item)
                    .FirstOrDefaultAsync(h => h.Id == hunterId);

                if (hunter == null)
                {
                    return NotFound("Caçador não encontrado.");
                }

                await RecalculateStats(hunter);
                await _context.SaveChangesAsync();

                return Ok(hunter);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Erro interno: {ex.Message}");
            }
        }

        [HttpPost("spend-point/{skillName}")]
        public async Task<IActionResult> SpendAttributePoint(string skillName)
        {
            try
            {
                (var hunterId, var error) = _getUserClaims();
                if (error != null) return error;

                var hunter = await _context.StatsUser.FindAsync(hunterId);
                if (hunter == null) return NotFound("Caçador não encontrado.");

                if (hunter.AttributePoints <= 0)
                {
                    return BadRequest(new { message = "Você não tem pontos de atributo para gastar." });
                }

                bool attributeIncreased = true;
                hunter.AttributePoints--;

                switch (skillName.ToLower())
                {
                    case "strength":
                        hunter.Strength++;
                        break;
                    case "dexterity":
                        hunter.Dexterity++;
                        break;
                    case "intelligence":
                        hunter.Intelligence++;
                        break;
                    case "constitution":
                        hunter.Constitution++;
                        break;
                    case "endurance":
                        hunter.Endurance++;
                        break;
                    default:
                        hunter.AttributePoints++;
                        attributeIncreased = false;
                        break;
                }

                if (!attributeIncreased)
                {
                    return BadRequest(new { message = "Nome do atributo inválido. (Use: strength, dexterity, intelligence, constitution, endurance)" });
                }

                await RecalculateStats(hunter);

                await _context.SaveChangesAsync();

                return Ok(hunter);
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
            if (hunter.EquippedArmorSlot != null)
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