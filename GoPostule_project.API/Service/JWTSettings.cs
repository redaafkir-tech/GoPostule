namespace GoPostule_project.API.Configurations
{
    //L'utilisateur envoie ses identifiants (LoginDto).
    //L'API vérifie et génère un texte crypté via le JwtService.
    //L'API met ce texte dans l'objet TokenResponseDto(le paquet cadeau).
    //Flutter reçoit ce paquet et peut lire : "Ah, voici le token, et je vois que l'utilisateur est un Admin".
    public class JWTSettings
    {
        public string Key { get; set; } = string.Empty;
        public string Issuer { get; set; } = string.Empty;
        public string Audience { get; set; } = string.Empty;
        public int DurationInDays { get; set; }
    }
}

