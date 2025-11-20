using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DailyRPG.Migrations
{
    /// <inheritdoc />
    public partial class Limiter : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Difficult",
                table: "Contracts",
                newName: "Difficulty");

            migrationBuilder.AddColumn<DateTime>(
                name: "CompletedAt",
                table: "Contracts",
                type: "datetime(6)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CompletedAt",
                table: "Contracts");

            migrationBuilder.RenameColumn(
                name: "Difficulty",
                table: "Contracts",
                newName: "Difficult");
        }
    }
}
