using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DailyRPG.Migrations
{
    /// <inheritdoc />
    public partial class DropSystem : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "HunterUserId",
                table: "Contracts",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_Contracts_HunterUserId",
                table: "Contracts",
                column: "HunterUserId");

            migrationBuilder.AddForeignKey(
                name: "FK_Contracts_StatsUser_HunterUserId",
                table: "Contracts",
                column: "HunterUserId",
                principalTable: "StatsUser",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Contracts_StatsUser_HunterUserId",
                table: "Contracts");

            migrationBuilder.DropIndex(
                name: "IX_Contracts_HunterUserId",
                table: "Contracts");

            migrationBuilder.DropColumn(
                name: "HunterUserId",
                table: "Contracts");
        }
    }
}
