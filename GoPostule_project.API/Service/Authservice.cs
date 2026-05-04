using GoPostule_project.API.DTos;
using GoPostule_project.Data;
using GoPostule_project.Data.Entitée;
using Microsoft.EntityFrameworkCore;

namespace GoPostule_project.API.Services
{
    // AuthService gère toute la logique d'authentification
    // Il est appelé par AuthController
    // Il utilise AppDbContext pour accéder à SQL Server
    // Il utilise JwtService pour générer le token
    public class AuthService
    {
        private readonly AppDbContext _db;
        private readonly JwtService _jwtService;

        // .NET injecte AppDbContext et JwtService automatiquement
        // grâce aux lignes AddScoped dans Program.cs
        public AuthService(AppDbContext db, JwtService jwtService)
        {
            _db = db;
            _jwtService = jwtService;
        }

        // ── INSCRIPTION ───────────────────────────────────────────
        public async Task<string> RegisterAsync(RegisterDto dto)
        {
            // ÉTAPE 1 : Vérifier si email déjà utilisé
            var emailExiste = await _db.Users
                .AnyAsync(u => u.Email == dto.Email);

            if (emailExiste)
                throw new Exception("Cet email est déjà utilisé.");

            // ÉTAPE 2 : Créer le nouvel utilisateur
            var user = new User
            {
                Nom = dto.Nom,
                Prenom = dto.Prenom,
                Email = dto.Email,
                Telephone = dto.Telephone,

                // ÉTAPE 3 : Hacher le mot de passe avec BCrypt
                // Jamais stocker le mot de passe en clair !
                Password = BCrypt.Net.BCrypt.HashPassword(dto.Password),

                // Toujours "candidat" — jamais "rh" ou "admin"
                Role = "candidat",
                CreatedAt = DateTime.UtcNow
            };

            // ÉTAPE 4 : Sauvegarder dans SQL Server
            _db.Users.Add(user);
            await _db.SaveChangesAsync();

            return "Compte créé avec succès.";
        }

        // ── CONNEXION ─────────────────────────────────────────────
        public async Task<TokenResponseDto> LoginAsync(LoginDto dto)
        {
            // ÉTAPE 1 : Chercher l'utilisateur par email
            var user = await _db.Users
                .FirstOrDefaultAsync(u => u.Email == dto.Email);

            if (user == null)
                throw new Exception("Email introuvable.");

            // ÉTAPE 2 : Vérifier le mot de passe avec BCrypt
            bool motDePasseCorrect = BCrypt.Net.BCrypt
                .Verify(dto.Password, user.Password);

            if (!motDePasseCorrect)
                throw new Exception("Mot de passe incorrect.");

            // ÉTAPE 3 : Générer le token JWT
            var token = _jwtService.GenerateToken(user);

            // ÉTAPE 4 : Retourner token + infos utilisateur
            return new TokenResponseDto
            {
                Token = token,
                Nom = user.Nom,
                Prenom = user.Prenom,
                Email = user.Email,
                Role = user.Role,
                ExpireAt = DateTime.UtcNow.AddDays(30)
            };
        }

        // ── MON PROFIL ────────────────────────────────────────────
        // Retourne l'utilisateur connecté par son ID
        // L'ID est extrait du token JWT dans le Controller
        public async Task<User?> GetMeAsync(int userId)
        {
            return await _db.Users.FindAsync(userId);
        }
    }
}