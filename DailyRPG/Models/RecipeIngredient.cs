using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;
using DailyRpg.Models;

namespace DailyRpg.Models
{
    public class RecipeIngredient
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int RecipeId { get; set; }

        [JsonIgnore]
        [ForeignKey("RecipeId")]
        public Recipe Recipe { get; set; } = null!;

        [Required]
        public int MaterialId { get; set; }

        [ForeignKey("MaterialId")]
        public virtual Item Material { get; set; } = null!;

        [Required]
        public int QuantityRequired { get; set; }


    }
}