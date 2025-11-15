using System.ComponentModel.DataAnnotations;

namespace DailyRpg.DTOs
{
    public class UserRegisterDto
    {
        [Required]
        [MinLength(3, ErrorMessage = "O nome de utilizador devbe ter pelo menos 3 caracteres")]
        public string Username { get; set; }

        [Required]
        [MinLength(6, ErrorMessage = "A senha deve ter pelo menos 6 caracteres")] 
        public string Password { get; set; }    
    }
}