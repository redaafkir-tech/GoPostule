using System;
using System.Collections.Generic;
using System.Text;

namespace GoPostule_project.Data.Entitée
{
    public class Offre
    {
        public int Id { get; set; }
        public string Titre { get; set; } = string.Empty;
        public string Entreprise { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Missions { get; set; } = string.Empty;
        public string ProfilRecherche { get; set; } = string.Empty;
        public string Competences { get; set; } = string.Empty;
        public string Localisation { get; set; } = string.Empty;
        public string Salaire { get; set; } = string.Empty;
        public string TypeContrat { get; set; } = string.Empty;
        public string Secteur { get; set; } = string.Empty;
        public DateTime? DateLimite { get; set; } //? Cela signifie que la date est optionnelle.
        public int PlacesDisponibles { get; set; } = 1;
        public bool Actif { get; set; } = true;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation
        public ICollection<Candidature> Candidature { get; set; }
            = new List<Candidature>();
    }
}
