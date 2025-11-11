using Microsoft.EntityFrameworkCore;
using DailyRpg.Models;


namespace DailyRpg.Data
{
    public class ApiDbContext : DbContext
    {
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<InventorySlot>()
                .HasOne(s => s.HunterUser) 
                .WithMany() 
                .HasForeignKey(s => s.HunterUserId)
                .OnDelete(DeleteBehavior.Cascade); 


            modelBuilder.Entity<HunterUser>()
                .HasOne(h => h.EquippedWeaponSlot) 
                .WithMany() 
                .HasForeignKey(h => h.EquippedWeaponSlotId) 
                .OnDelete(DeleteBehavior.SetNull);


            modelBuilder.Entity<HunterUser>()
                .HasOne(h => h.EquippedArmorSlot) 
                .WithMany()
                .HasForeignKey(h => h.EquippedArmorSlotId) 
                .OnDelete(DeleteBehavior.SetNull); 
        }
        public ApiDbContext(DbContextOptions<ApiDbContext> options) : base(options)
        {
        }
        public DbSet<Contract> Contracts { get; set; }
        public DbSet<HunterUser> StatsUser { get; set; }
        public DbSet<User> Users { get; set; }

        public DbSet<Item> Items { get; set; } = null!;

        public DbSet<InventorySlot> InventorySlots { get; set; } = null!;

        public DbSet<Recipe> Recipes { get; set; } = null!;
        public DbSet<RecipeIngredient> RecipeIngredients { get; set; } = null!;

        public DbSet<Boss> Bosses { get; set; } = null!;

        
        
     } 
}