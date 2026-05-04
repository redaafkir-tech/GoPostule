using System;
using System.Collections.Generic;
using System.Text;

namespace GoPostule_project.Data.Entitée
{
    public class HistoriquePhase
    {
        public int Id { get; set; }
        public int CandidatureId { get; set; }
        public string Phase { get; set; } = string.Empty;
        public string Commentaire { get; set; } = string.Empty;
        public DateTime Date { get; set; } = DateTime.UtcNow;

        // Navigation
        public Candidature Candidature { get; set; } = null!;
    }
}
