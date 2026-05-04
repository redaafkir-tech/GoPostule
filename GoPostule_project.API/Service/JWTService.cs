using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using GoPostule_project.API.Configurations;
using GoPostule_project.Data.Entitée;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace GoPostule_project.API.Services
{
    // C'est lui qui UTILISE JWTSettings
    // pour créer le vrai token JWT
    public class JwtService
    {
        private readonly JWTSettings _jwtSettings;

        public JwtService(IOptions<JWTSettings> jwtSettings)
        {
            _jwtSettings = jwtSettings.Value;
        }

        public string GenerateToken(User user)
        {
            // ÉTAPE 1 : Clé cryptographique
            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(_jwtSettings.Key));

            // ÉTAPE 2 : Algorithme HmacSha256
            var creds = new SigningCredentials(
                key, SecurityAlgorithms.HmacSha256);

            // ÉTAPE 3 : Contenu du token
            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Email,          user.Email),
                new Claim(ClaimTypes.Role,           user.Role),
                new Claim(ClaimTypes.Name,           $"{user.Nom} {user.Prenom}"),
            };

            // ÉTAPE 4 : Construire le token
            var token = new JwtSecurityToken(
                issuer: _jwtSettings.Issuer,
                audience: _jwtSettings.Audience,
                claims: claims,
                expires: DateTime.UtcNow.AddDays(_jwtSettings.DurationInDays),
                signingCredentials: creds
            );

            // ÉTAPE 5 : Retourner en string
            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}