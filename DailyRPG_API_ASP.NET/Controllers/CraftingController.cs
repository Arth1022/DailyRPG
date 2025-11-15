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
    public class CraftingController : ControllerBase
    {
        private readonly ApiDbContext _context;

        public CraftingController(ApiDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetRecipes()
        {
            try
            {

                var recipes = await _context.Recipes
    
                    .Include(r => r.ItemCreated) 

                    .Include(r => r.RecipeIngredients)
        
                        .ThenInclude(ri => ri.Material) 
                    .ToListAsync();

                return Ok(recipes);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Erro interno: {ex.Message}");
            }
        }


        [HttpPost("{recipeId}")]
        public async Task<IActionResult> CraftItem(int recipeId)
        {
            try
            {
                (var hunterId, var error) = _getUserClaims();
                if (error != null) return error;

                var recipe = await _context.Recipes
                    .Include(r => r.RecipeIngredients) 
                    .Include(r => r.ItemCreated)     
                    .FirstOrDefaultAsync(r => r.Id == recipeId);

                if (recipe == null)
                {
                    return NotFound("Receita não encontrada.");
                }

                var hunterInventorySlots = await _context.InventorySlots
                    .Where(s => s.HunterUserId == hunterId)
                    .ToListAsync();
                
                var hunterInventoryDict = hunterInventorySlots.ToDictionary(s => s.ItemId, s => s);

                foreach (var ingredient in recipe.RecipeIngredients)
                {
                    if (!hunterInventoryDict.TryGetValue(ingredient.MaterialId, out var slot))
                    {
                        return BadRequest($"Material insuficiente: {ingredient.Material.Name}");
                    }
                    if (slot.Quantity < ingredient.QuantityRequired)
                    {
                        return BadRequest($"Material insuficiente: {ingredient.Material.Name}. (Necessário: {ingredient.QuantityRequired}, Você tem: {slot.Quantity})");
                    }
                }

                foreach (var ingredient in recipe.RecipeIngredients)
                {
                    var slotToConsume = hunterInventoryDict[ingredient.MaterialId];
                    
                    slotToConsume.Quantity -= ingredient.QuantityRequired;

                    if (slotToConsume.Quantity <= 0)
                    {
                        _context.InventorySlots.Remove(slotToConsume);
                    }
                    else
                    {
                        _context.InventorySlots.Update(slotToConsume);
                    }
                }

                var itemToAdd = recipe.ItemCreated;
                
                if (hunterInventoryDict.TryGetValue(itemToAdd.Id, out var existingSlot))
                {
                    existingSlot.Quantity++;
                    _context.InventorySlots.Update(existingSlot);
                }
                else
                {
                    var newSlot = new InventorySlot
                    {
                        HunterUserId = hunterId.Value,
                        ItemId = itemToAdd.Id,
                        Quantity = 1
                    };
                    await _context.InventorySlots.AddAsync(newSlot);
                }

                await _context.SaveChangesAsync();

                return Ok(new { message = $"Você criou 1x {itemToAdd.Name}!" });
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