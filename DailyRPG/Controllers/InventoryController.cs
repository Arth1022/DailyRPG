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
                    .Include(s => s.Item) // "Inclui" os dados do Item
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

                // "Encontra" o Caçador e o Slot (com o Item)
                var hunter = await _context.StatsUser.FindAsync(hunterId);
                
                var slot = await _context.InventorySlots
                    .Include(s => s.Item) // "Inclui" o Item
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

                // Lógica de "Tipo"
                switch (item.Type)
                {
                    // --- Caso 1: "Usar" (Poção) ---
                    case ItemType.Consumable:
                        // (A sua lógica de 'Poção' - sem mudanças)
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

                    // --- Caso 2: "Equipar" (Arma ou Armadura) ---
                    case ItemType.Equipament:
                        // (A sua lógica de 'EquipType' - "operada")
                        if (item.EquipType == EquipmentType.Weapon)
                        {
                            if (hunter.EquippedWeaponSlotId == slot.Id)
                            {
                                // "Desequipando" (Unequip)
                                hunter.EquippedWeaponSlotId = null; 
                                message = $"Você desequipou {item.Name}.";
                            }
                            else
                            {
                                // "Equipando" (Equip)
                                hunter.EquippedWeaponSlotId = slot.Id;
                                message = $"Você equipou {item.Name}.";
                            }
                        }
                        else if (item.EquipType == EquipmentType.Armor)
                        {
                            if (hunter.EquippedArmorSlotId == slot.Id)
                            {
                                // "Desequipando" (Unequip)
                                hunter.EquippedArmorSlotId = null;
                                message = $"Você desequipou {item.Name}.";
                            }
                            else
                            {
                                // "Equipando" (Equip)
                                hunter.EquippedArmorSlotId = slot.Id;
                                message = $"Você equipou {item.Name}.";
                            }
                        }
                        break;
                }

                // --- 4. "RECALCULAR" OS STATS (A "MAGIA" DA FASE 10) ---
                // (Chama o "Recalcular" *sempre* que equipar ou desequipar)
                await RecalculateStats(hunter);

                // 5. "Salva" o Caçador (com os novos stats)
                //    e o Inventário (com a poção gasta)
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
            // 1. "Encontra" os Itens Equipados
            Item? equippedWeapon = null;
            if (hunter.EquippedWeaponSlotId != null)
            {
                var weaponSlot = await _context.InventorySlots
                    .Include(s => s.Item) // "Inclui" o Item
                    .FirstOrDefaultAsync(s => s.Id == hunter.EquippedWeaponSlotId);
                if (weaponSlot != null) equippedWeapon = weaponSlot.Item;
            }

            Item? equippedArmor = null;
            if (hunter.EquippedArmorSlotId != null)
            {
                var armorSlot = await _context.InventorySlots
                    .Include(s => s.Item) // "Inclui" o Item
                    .FirstOrDefaultAsync(s => s.Id == hunter.EquippedArmorSlotId);
                if (armorSlot != null) equippedArmor = armorSlot.Item;
            }

            // 2. "Reseta" e "Calcula" os Stats

            // --- HP (Baseado em 'Constitution') ---
            // (Base 100 HP + 10 HP por ponto de 'Constitution')
            int oldMaxHp = hunter.MaxHp;
            hunter.MaxHp = 100 + (hunter.Constitution * 10);

            // (Cura o jogador pelo HP ganho, se não estiver cheio)
            if (hunter.CurrentHp != oldMaxHp && hunter.CurrentHp < hunter.MaxHp)
            {
                hunter.CurrentHp += (hunter.MaxHp - oldMaxHp);
                if (hunter.CurrentHp > hunter.MaxHp) hunter.CurrentHp = hunter.MaxHp;
            }
            // (Se o jogador "perdeu" HP Máx (ex: 'debuff' futuro),
            //  "corta" o HP atual)
            if (hunter.CurrentHp > hunter.MaxHp)
            {
                hunter.CurrentHp = hunter.MaxHp;
            }

            // --- Defesa (Baseado em 'Endurance') ---
            // (Base Defesa = 'Endurance' + Bónus da Armadura)
            hunter.Defense = hunter.Endurance; // (Defesa "base" da Skill)
            if (equippedArmor != null)
            {
                hunter.Defense += equippedArmor.EffectValue; // (Soma a Armadura)
            }

            // --- Dano (Baseado em 'Strength', 'Dexterity', 'Intelligence') ---
            
            // "Dano Desarmado" (Se nenhuma arma equipada)
            // (O Dano Desarmado "escala" com 'Strength' por padrão)
            hunter.Damage = hunter.Strength; 

            if (equippedWeapon != null)
            {
                // Dano = Dano Base da Arma
                hunter.Damage = equippedWeapon.EffectValue;

                // Adiciona o Bónus do Atributo (Skill)
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