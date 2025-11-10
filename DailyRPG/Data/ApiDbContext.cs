using Microsoft.EntityFrameworkCore;
using DailyRpg.Models;

namespace DailyRpg.Data
{
    public class ApiDbContext : DbContext
    {
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<User>().HasOne(u => u.HunterUser).WithOne().HasForeignKey<HunterUser>(h => h.UserId);
        }
        //construtor padrao:
        public ApiDbContext(DbContextOptions<ApiDbContext> options) : base(options)
        {
        }
        public DbSet<Contract> Contracts { get; set; }
        public DbSet<HunterUser> StatsUser { get; set; }
        public DbSet<User> Users { get; set; }

        public DbSet<Item> Items { get; set; } = null!;

        public DbSet<InventorySlot> InventorySlots { get; set; } = null!;
     } 
}