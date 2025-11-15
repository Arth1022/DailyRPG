using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using DailyRpg.Models;
using System.Collections.Generic;

namespace DailyRpg.Models
{
    public class Recipe
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = string.Empty;

        public string Description { get; set; } = string.Empty;

        [Required]
        public int ItemCreatedId { get; set; }

        [ForeignKey("ItemCreatedId")]
        public virtual Item ItemCreated { get; set; } = null!;

        public virtual ICollection<RecipeIngredient> RecipeIngredients { get; set; } = null!;
        
    }
}