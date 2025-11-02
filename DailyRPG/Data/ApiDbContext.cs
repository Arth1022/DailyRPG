using Microsoft.EntityFrameworkCore;
using DailyRpg.Models;

namespace ApiDbContext.Data
{
    public class ApiDbContext_class : DbContext//Db context vem do padrao do EF
    {
        //construtor padrao:
        public ApiDbContext_class(DbContextOptions<ApiDbContext_class> options) : base(options)
        {
        }
        //tabelas  
        //Classe    //nome da tabela
        public DbSet<Contract> Contracts { get; set; }
        public DbSet<HunterUser> StatsUser { get; set; }

    } 
}