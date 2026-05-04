using GoPostule_project.Data.Entitée;
using Microsoft.EntityFrameworkCore;

namespace GoPostule_project.Data
{
    //Le AppDbContext est le fichier C# qui relie tous les modèles à la base de données SQL Server.
    //C'est lui qui dit à Entity Framework Core quelles tables créer et comment elles sont liées entre elles.
    public class AppDbContext : DbContext //i hérite de DbContext pour utiliser Entity Framework
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options) { }
        //  Une ligne est créer table Users dans SQL Server
        public DbSet<User> Users { get; set; }
        public DbSet<Offre> Offres { get; set; }
        public DbSet<Candidature> Candidatures { get; set; }
        public DbSet<HistoriquePhase> HistoriquePhases { get; set; }
        public DbSet<Dossier> Dossiers { get; set; }
        public DbSet<Reclamation> Reclamations { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Email unique
            modelBuilder.Entity<User>() //je configure la table Users
                .HasIndex(u => u.Email) //Créer index sur Email CREATE UNIQUE INDEX IX_Email ON Users(Email)
                .IsUnique();

            // Un candidat ne peut postuler qu'UNE FOIS à la même offre
            modelBuilder.Entity<Candidature>()
                .HasIndex(c => new { c.UserId, c.OffreId })
                .IsUnique();

            // Relation User → Candidature
            modelBuilder.Entity<Candidature>()
                .HasOne(c => c.User) // HasOne  → coté enfant
                .WithMany(u =>u.Candidature)  //WithMany → coté parent
                .HasForeignKey(c => c.UserId)
                .OnDelete(DeleteBehavior.Restrict); // Si tu supprimes leParent (l'Utilisateur) SQL supprime automatiquement tous les Enfants

            // Relation Candidature → HistoriquePhases
            modelBuilder.Entity<HistoriquePhase>()
               .HasOne(h => h.Candidature)
               .WithMany(c => c.HistoriquePhases)
               .HasForeignKey(h => h.CandidatureId)
               .OnDelete(DeleteBehavior.Cascade); // interdit la suppression du Parent tant qu'il a des Enfants.

            // Relation Candidature → Dossier
            modelBuilder.Entity<Dossier>()
                .HasOne(d => d.Candidature)
                .WithOne(c => c.Dossier)
                .HasForeignKey<Dossier>(d => d.CandidatureId) //un parent a un seul enfant
                .OnDelete(DeleteBehavior.Restrict);


            // Relation User → Dossiers
            modelBuilder.Entity<Dossier>()
               .HasOne(d => d.User)
               .WithMany(u => u.Dossiers)
               .HasForeignKey(d => d.UserId)
               .OnDelete(DeleteBehavior.Restrict);

            // Relation Candidature → Reclamations
            modelBuilder.Entity<Reclamation>()
                .HasOne(r => r.Candidature)
                .WithMany(c => c.Reclamations)
                .HasForeignKey(r => r.CandidatureId)
                .OnDelete(DeleteBehavior.Restrict);

            // Relation User → Reclamations
            modelBuilder.Entity<Reclamation>()
                .HasOne(r => r.User)
                .WithMany(u => u.Reclamation)
                .HasForeignKey(r => r.UserId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }

}