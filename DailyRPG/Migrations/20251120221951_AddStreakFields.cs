using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DailyRPG.Migrations
{
    /// <inheritdoc />
    public partial class AddStreakFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "CurrentStreak",
                table: "StatsUser",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<DateTime>(
                name: "LastActivityDate",
                table: "StatsUser",
                type: "datetime(6)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CurrentStreak",
                table: "StatsUser");

            migrationBuilder.DropColumn(
                name: "LastActivityDate",
                table: "StatsUser");
        }
    }
}
