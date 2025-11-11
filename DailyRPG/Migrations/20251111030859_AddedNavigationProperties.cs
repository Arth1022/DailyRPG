using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DailyRPG.Migrations
{
    /// <inheritdoc />
    public partial class AddedNavigationProperties : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "EquippedArmorslotId",
                table: "StatsUser",
                newName: "EquippedArmorSlotId");

            migrationBuilder.CreateIndex(
                name: "IX_StatsUser_EquippedArmorSlotId",
                table: "StatsUser",
                column: "EquippedArmorSlotId");

            migrationBuilder.CreateIndex(
                name: "IX_StatsUser_EquippedWeaponSlotId",
                table: "StatsUser",
                column: "EquippedWeaponSlotId");

            migrationBuilder.AddForeignKey(
                name: "FK_StatsUser_InventorySlots_EquippedArmorSlotId",
                table: "StatsUser",
                column: "EquippedArmorSlotId",
                principalTable: "InventorySlots",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_StatsUser_InventorySlots_EquippedWeaponSlotId",
                table: "StatsUser",
                column: "EquippedWeaponSlotId",
                principalTable: "InventorySlots",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_StatsUser_InventorySlots_EquippedArmorSlotId",
                table: "StatsUser");

            migrationBuilder.DropForeignKey(
                name: "FK_StatsUser_InventorySlots_EquippedWeaponSlotId",
                table: "StatsUser");

            migrationBuilder.DropIndex(
                name: "IX_StatsUser_EquippedArmorSlotId",
                table: "StatsUser");

            migrationBuilder.DropIndex(
                name: "IX_StatsUser_EquippedWeaponSlotId",
                table: "StatsUser");

            migrationBuilder.RenameColumn(
                name: "EquippedArmorSlotId",
                table: "StatsUser",
                newName: "EquippedArmorslotId");
        }
    }
}
