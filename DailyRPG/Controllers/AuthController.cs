using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DailyRpg.Data;
using DailyRpg.Models;
using DailyRpg.DTOs;
using BCrypt.Net;

namespace DailyRpg.Controllers
{
    [ApiController]
    [Route("api/[Controller]")]
    public class AuthController : ControllerBase
    {
        private readonly ApiDbContext _context; // Ligacao com o DB

        public AuthController(ApiDbContext context)
        {
            _context = context;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register(UserRegisterDto request)
        {
            if (await _context.Users.AnyAsync(u => u.UserName == request.Username))
            {
                return BadRequest("Este nome de utilizador já esta sendo utilizado");
            }

            string passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

            var newHunter = new HunterUser
            {
                HunterName = request.Username,
                Level = 1,
                CurrentHp = 100,
                MaxHp = 100,
                CurrentXp = 0,
                NextLevelXp = 700,
                CurrentCoins = 0,
            };

            var newUser = new User
            {
                UserName = request.Username,
                PasswordHash = passwordHash,
                HunterUser = newHunter
            };

            _context.Users.Add(newUser);

            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(Register), new { id = newUser.Id }, newUser);
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(UserLoginDto request)
        {
            var user = await _context.Users.FirstOrDefaultAsync(u => u.UserName == request.Username);

            if (user == null)
            {
                return Unauthorized("Credenciais inválidas.");
            }

            if (!BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            {
                return Unauthorized("Credenciais inválidas.");
            }

            return Ok("Login bem-sucedido!");
        }

    }
}