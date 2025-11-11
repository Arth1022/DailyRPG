using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DailyRPG.Migrations
{
    /// <inheritdoc />
    public partial class Fodase : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_recipeIngredients_Items_MaterialId",
                table: "recipeIngredients");

            migrationBuilder.DropForeignKey(
                name: "FK_recipeIngredients_Recipes_RecipeId",
                table: "recipeIngredients");

            migrationBuilder.DropPrimaryKey(
                name: "PK_recipeIngredients",
                table: "recipeIngredients");

            migrationBuilder.DropColumn(
                name: "ItemCreateId",
                table: "Recipes");

            migrationBuilder.RenameTable(
                name: "recipeIngredients",
                newName: "RecipeIngredients");

            migrationBuilder.RenameIndex(
                name: "IX_recipeIngredients_RecipeId",
                table: "RecipeIngredients",
                newName: "IX_RecipeIngredients_RecipeId");

            migrationBuilder.RenameIndex(
                name: "IX_recipeIngredients_MaterialId",
                table: "RecipeIngredients",
                newName: "IX_RecipeIngredients_MaterialId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_RecipeIngredients",
                table: "RecipeIngredients",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_RecipeIngredients_Items_MaterialId",
                table: "RecipeIngredients",
                column: "MaterialId",
                principalTable: "Items",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_RecipeIngredients_Recipes_RecipeId",
                table: "RecipeIngredients",
                column: "RecipeId",
                principalTable: "Recipes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_RecipeIngredients_Items_MaterialId",
                table: "RecipeIngredients");

            migrationBuilder.DropForeignKey(
                name: "FK_RecipeIngredients_Recipes_RecipeId",
                table: "RecipeIngredients");

            migrationBuilder.DropPrimaryKey(
                name: "PK_RecipeIngredients",
                table: "RecipeIngredients");

            migrationBuilder.RenameTable(
                name: "RecipeIngredients",
                newName: "recipeIngredients");

            migrationBuilder.RenameIndex(
                name: "IX_RecipeIngredients_RecipeId",
                table: "recipeIngredients",
                newName: "IX_recipeIngredients_RecipeId");

            migrationBuilder.RenameIndex(
                name: "IX_RecipeIngredients_MaterialId",
                table: "recipeIngredients",
                newName: "IX_recipeIngredients_MaterialId");

            migrationBuilder.AddColumn<int>(
                name: "ItemCreateId",
                table: "Recipes",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddPrimaryKey(
                name: "PK_recipeIngredients",
                table: "recipeIngredients",
                column: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_recipeIngredients_Items_MaterialId",
                table: "recipeIngredients",
                column: "MaterialId",
                principalTable: "Items",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_recipeIngredients_Recipes_RecipeId",
                table: "recipeIngredients",
                column: "RecipeId",
                principalTable: "Recipes",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
