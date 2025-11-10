using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DailyRPG.Migrations
{
    /// <inheritdoc />
    public partial class AddedEquipmentStats : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Damage",
                table: "StatsUser",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "Defense",
                table: "StatsUser",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "EquipType",
                table: "Items",
                type: "int",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Damage",
                table: "StatsUser");

            migrationBuilder.DropColumn(
                name: "Defense",
                table: "StatsUser");

            migrationBuilder.DropColumn(
                name: "EquipType",
                table: "Items");
        }
    }
}
