using GoPostule_project.API.Services;
using GoPostule_project.Data;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// 1. CONFIGURATION DE LA BASE DE DONNÉES
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        b => b.MigrationsAssembly("GoPostule_project.Data")
    ));

// --- AJOUT CRUCIAL ICI ---
// On lie le JSON à la classe JWTSettings pour que JwtService puisse lire la Key
builder.Services.Configure<GoPostule_project.API.Configurations.JWTSettings>(
    builder.Configuration.GetSection("JWT"));

// 2. CONFIGURATION DU SERVICE JWT
var jwtSettings = builder.Configuration.GetSection("JWT");
var jwtKey = jwtSettings["Key"];
var jwtIssuer = jwtSettings["Issuer"];
var jwtAudience = jwtSettings["Audience"];

// Vérification de sécurité (Optionnel mais recommandé)
if (string.IsNullOrEmpty(jwtKey)) {
    throw new Exception("La clé JWT est introuvable dans appsettings.json !");
}

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtIssuer,
        ValidAudience = jwtAudience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey))
    };
});
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<JwtService>();
builder.Services.AddScoped<AuthService>();

var app = builder.Build();

// 3. CONFIGURATION DU PIPELINE (L'ORDRE EST TRÈS IMPORTANT ICI)
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseStaticFiles();

// AJOUT IMPORTANT : L'authentification doit TOUJOURS être avant l'autorisation
app.UseAuthentication(); // "Qui es-tu ?" (Vérifie le Token)
app.UseAuthorization();  // "As-tu le droit ?" (Vérifie le Rôle : Admin/Candidat)

app.MapControllers();

app.Run();