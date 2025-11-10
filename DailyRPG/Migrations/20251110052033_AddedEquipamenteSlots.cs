using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DailyRPG.Migrations
{
    /// <inheritdoc />
    public partial class AddedEquipamenteSlots : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "HealingPotions",
                table: "StatsUser");

            migrationBuilder.DropColumn(
                name: "XpPotions",
                table: "StatsUser");

            migrationBuilder.AddColumn<int>(
                name: "EquippedArmorslotId",
                table: "StatsUser",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "EquippedWeaponSlotId",
                table: "StatsUser",
                type: "int",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "EquippedArmorslotId",
                table: "StatsUser");

            migrationBuilder.DropColumn(
                name: "EquippedWeaponSlotId",
                table: "StatsUser");

            migrationBuilder.AddColumn<int>(
                name: "HealingPotions",
                table: "StatsUser",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "XpPotions",
                table: "StatsUser",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }
    }
}
