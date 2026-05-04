using System;
using System.Collections.Generic;
using System.Text;

namespace GoPostule_project.Data.Entitée
{
    public class Candidature
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int OffreId { get; set; }
        public string LettreMotivation { get; set; } = string.Empty;


        // Valeurs : soumise | examen_dossier | validee | rejetee | admise
        public string PhaseActuelle { get; set; } = "soumise";

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        
        //Elle permet d'accéder aux infos de l'utilisateur directement depuis la candidature.
        public User User { get; set; } = null!; //cette propriété ne sera pas nulle une fois que les données seront chargées depuis la base"
        public Offre Offre { get; set; } = null!;

        public ICollection<HistoriquePhase> HistoriquePhases { get; set; }
            = new List<HistoriquePhase>();
        public ICollection<Reclamation> Reclamations { get; set; }
            = new List<Reclamation>();
        public Dossier? Dossier { get; set; }
    }
}
