using System.ComponentModel.DataAnnotations;

namespace DailyRpg.DTOs
{
    public class UserLoginDto
    {
        [Required]
        public string Username { get; set; }

        [Required]
        public string Password { get; set; }
    }
}