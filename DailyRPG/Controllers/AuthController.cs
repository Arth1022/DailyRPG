using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DailyRpg.Data;
using DailyRpg.Models;
using DailyRpg.DTOs;
using BCrypt.Net;
using System.Security.Claims; 
using System.IdentityModel.Tokens.Jwt; 
using Microsoft.IdentityModel.Tokens; 
using System.Text;

namespace DailyRpg.Controllers
{
    [ApiController]
    [Route("api/[Controller]")]
    public class AuthController : ControllerBase
    {
        private readonly ApiDbContext _context; // Ligacao com o DB

        private readonly IConfiguration _configuration;

        public AuthController(ApiDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }
        private string CreateToken(User user)
    {
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.UserName)
        
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(
            _configuration.GetSection("Jwt:Key").Value!
        ));

        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha512Signature);

        var tokenDescriptor = new SecurityTokenDescriptor
        {
            Subject = new ClaimsIdentity(claims),
            Expires = DateTime.Now.AddDays(1),
            SigningCredentials = creds,
            Issuer = _configuration.GetSection("Jwt:Issuer").Value!,
            Audience = _configuration.GetSection("Jwt:Audience").Value!
        };

        var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);
        
        return tokenHandler.WriteToken(token);
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
                CurrentCoins = 20,
                Damage = 1,
                Defense = 0,

            };
            var firstBoss = await _context.Bosses
                    .FirstOrDefaultAsync(b => b.Level == 1);

                if (firstBoss != null)
                {
                    
                    newHunter.CurrentBossId = firstBoss.Id;
                    newHunter.CurrentBossHp = firstBoss.MaxHp; 
                }
                
                

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

            string token = CreateToken(user);

            return Ok(new { token = token });
        }

    }
}