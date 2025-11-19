using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DailyRPG.Migrations
{
    /// <inheritdoc />
    public partial class AdicionarPvP : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "BattleSession",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("MySql:ValueGenerationStrategy", MySqlValueGenerationStrategy.IdentityColumn),
                    HunterId = table.Column<int>(type: "int", nullable: false),
                    OpponentId = table.Column<int>(type: "int", nullable: false),
                    PlayerCurrentHp = table.Column<int>(type: "int", nullable: false),
                    EnemyCurrentHp = table.Column<int>(type: "int", nullable: false),
                    PlayerMaxHp = table.Column<int>(type: "int", nullable: false),
                    EnemyMaxHp = table.Column<int>(type: "int", nullable: false),
                    IsFinished = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    PlayerWon = table.Column<bool>(type: "tinyint(1)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime(6)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BattleSession", x => x.Id);
                })
                .Annotation("MySql:CharSet", "utf8mb4");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "BattleSession");
        }
    }
}
