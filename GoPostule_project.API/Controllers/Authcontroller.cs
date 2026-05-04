using GoPostule_project.API.DTos;
using GoPostule_project.API.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace GoPostule_project.API.Controllers
{
    // [ApiController] → active la validation automatique des DTOs
    // [Route] → définit l'URL de base 
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly AuthService _authService;

        // .NET injecte AuthService automatiquement
        public AuthController(AuthService authService)
        {
            _authService = authService;
        }

        // ── POST /api/auth/register ───────────────────────────────
        // Route publique — pas besoin de token
        // Flutter envoie : nom, prénom, email, téléphone, mot de passe
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto dto)
        {
            try
            {
                var message = await _authService.RegisterAsync(dto);
                // 200 OK + message de succès
                return Ok(new { message });
            }
            catch (Exception ex)
            {
                // 400 Bad Request + message d'erreur
                return BadRequest(new { message = ex.Message });
            }
        }

        // ── POST /api/auth/login ──────────────────────────────────
        // Route publique — pas besoin de token
        // Flutter envoie : email + mot de passe
        // Flutter reçoit : token JWT + infos utilisateur
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            try
            {
                var result = await _authService.LoginAsync(dto);
                // 200 OK + token + infos
                return Ok(result);
            }
            catch (Exception ex)
            {
                // 401 Unauthorized + message d'erreur
                return Unauthorized(new { message = ex.Message });
            }
        }

        // ── GET /api/auth/me ──────────────────────────────────────
        // Route protégée — token JWT obligatoire
        // [Authorize] vérifie automatiquement le token
        // Flutter envoie : token dans le header Authorization
        // Flutter reçoit : infos du profil connecté
        [HttpGet("me")]
        [Authorize]
        public async Task<IActionResult> GetMe()
        {
            // Extraire l'ID de l'utilisateur depuis le token JWT
            // ClaimTypes.NameIdentifier = l'ID stocké dans le token
            var userId = int.Parse(
                User.FindFirstValue(ClaimTypes.NameIdentifier)!);

            var user = await _authService.GetMeAsync(userId);

            if (user == null)
                return NotFound(new { message = "Utilisateur introuvable." });

            // Retourner les infos sans le mot de passe
            return Ok(new
            {
                user.Id,
                user.Nom,
                user.Prenom,
                user.Email,
                user.Telephone,
                user.Role
            });
        }
    }
}