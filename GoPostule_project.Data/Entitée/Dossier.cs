using System;
using System.Collections.Generic;
using System.Text;

namespace GoPostule_project.Data.Entitée
{
    public class Dossier
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int CandidatureId { get; set; }
        public string Nom { get; set; } = string.Empty;
        public string Prenom { get; set; } = string.Empty;

        // Chemins des fichiers uploadés sur le serveur
        public string CheminCIN { get; set; } = string.Empty;
        public string CheminDiplome { get; set; } = string.Empty;
        public string CheminCV { get; set; } = string.Empty;
        public string CheminPhoto { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation
        public User User { get; set; } = null!;
        public Candidature Candidature { get; set; } = null!;
    }
}
