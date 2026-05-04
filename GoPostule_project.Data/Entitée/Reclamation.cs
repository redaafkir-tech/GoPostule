using System;
using System.Collections.Generic;
using System.Text;

namespace GoPostule_project.Data.Entitée
{
    public class Reclamation
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int CandidatureId { get; set; }
        public string Objet { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;

        // Valeurs : en_attente | en_traitement | resolue | rejetee
        public string Statut { get; set; } = "en_attente";

        public string? ReponseAdmin { get; set; }
        public DateTime? DateReponse { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation
        public User User { get; set; } = null!;
        public Candidature Candidature { get; set; } = null!;
    }
}
