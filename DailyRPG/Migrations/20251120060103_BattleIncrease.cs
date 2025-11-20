using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DailyRPG.Migrations
{
    /// <inheritdoc />
    public partial class BattleIncrease : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "HunterUserId1",
                table: "InventorySlots",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_InventorySlots_HunterUserId1",
                table: "InventorySlots",
                column: "HunterUserId1");

            migrationBuilder.AddForeignKey(
                name: "FK_InventorySlots_StatsUser_HunterUserId1",
                table: "InventorySlots",
                column: "HunterUserId1",
                principalTable: "StatsUser",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_InventorySlots_StatsUser_HunterUserId1",
                table: "InventorySlots");

            migrationBuilder.DropIndex(
                name: "IX_InventorySlots_HunterUserId1",
                table: "InventorySlots");

            migrationBuilder.DropColumn(
                name: "HunterUserId1",
                table: "InventorySlots");
        }
    }
}
