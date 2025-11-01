using Microsoft.EntityFrameworkCore;
using ApiDbContext.Data;
using Microsoft.VisualBasic;
using Microsoft.AspNetCore.Connections;
using Microsoft.Extensions.Options;

var builder = WebApplication.CreateBuilder(args);

//string de conexao
var connectionString = builder.Configuration.GetConnectionString("conexaoMySQL");

builder.Services.AddDbContext<ApiDbContext_class>(options =>
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString))
);

//Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add o CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterApp",
        policy => policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod());
});

var app = builder.Build();


//Swagger
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

//CORS
app.UseCors("AllowFlutterApp");

app.MapControllers();

app.Run();