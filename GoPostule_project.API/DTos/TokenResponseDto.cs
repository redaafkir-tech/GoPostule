namespace GoPostule_project.API.DTos
{
    //Ce que le serveur renvoie après connexion réussie
    public class TokenResponseDto
    {
        public string Nom { get; set; } = string.Empty;
        public string Prenom { get; set; } = string.Empty;
        public string Token { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
        public DateTime ExpireAt { get; set; }
    }
}
