using System;
using System.Collections.Generic;
using System.Text;

namespace GoPostule_project.Data.Entitée
{
    public class User
    {
        public int Id { get; set; }
        public string Nom { get; set; } = string.Empty; //C'est une sécurité pour éviter les erreurs Null
        public string Prenom { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string Telephone { get; set; } = string.Empty;
        public string Role { get; set; } = "candidat";
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow; //Enregistre automatiquement la date d'inscription

        //  relations avec les autres tables
        public ICollection<Candidature> Candidature { get; set; } //Relation 1 à N
            = new List<Candidature>();
        public ICollection<Reclamation> Reclamation { get; set; }
            = new List<Reclamation>();
        public ICollection<Dossier> Dossiers { get; set; }
            = new List<Dossier>();
    }
    
}
