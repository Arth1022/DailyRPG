using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace DailyRpg.Models
{
    public class InventorySlot
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int HunterUserId { get; set; }

        [JsonIgnore]
        [ForeignKey("HunterUserId")]
        public virtual HunterUser HunterUser { get; set; } = null!;

        [Required]
        public int ItemId { get; set; }

        [ForeignKey("ItemId")]
        public virtual Item Item { get; set; } = null!;

        [Required]
        public int Quantity { get; set; }
    }
}