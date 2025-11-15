using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DailyRPG.Migrations
{
    /// <inheritdoc />
    public partial class AddedSkillAttributes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "AttributePoints",
                table: "StatsUser",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "Constitution",
                table: "StatsUser",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "Dexterity",
                table: "StatsUser",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "Endurance",
                table: "StatsUser",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "Intelligence",
                table: "StatsUser",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "Strength",
                table: "StatsUser",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "SkillAffinity",
                table: "Items",
                type: "longtext",
                nullable: false)
                .Annotation("MySql:CharSet", "utf8mb4");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AttributePoints",
                table: "StatsUser");

            migrationBuilder.DropColumn(
                name: "Constitution",
                table: "StatsUser");

            migrationBuilder.DropColumn(
                name: "Dexterity",
                table: "StatsUser");

            migrationBuilder.DropColumn(
                name: "Endurance",
                table: "StatsUser");

            migrationBuilder.DropColumn(
                name: "Intelligence",
                table: "StatsUser");

            migrationBuilder.DropColumn(
                name: "Strength",
                table: "StatsUser");

            migrationBuilder.DropColumn(
                name: "SkillAffinity",
                table: "Items");
        }
    }
}
