class EmailService {
  // Plus tard, tu connecteras ça à N8N via une API

  static Future<bool> sendConcoursResultEmail({
    required String candidatEmail,
    required String candidatNom,
    required String offreTitre,
    required String typeConcours, // 'écrit' ou 'oral'
    required bool isAdmis,
    required DateTime dateConcours,
  }) async {
    try {
      // Ici tu feras un appel API vers ton workflow N8N
      // Exemple :
      /*
      final response = await http.post(
        Uri.parse('http://ton-serveur-n8n:5678/webhook/send-concours-email'),
        body: jsonEncode({
          'email': candidatEmail,
          'nom': candidatNom,
          'offre': offreTitre,
          'typeConcours': typeConcours,
          'resultat': isAdmis ? 'admis' : 'rejete',
          'dateConcours': dateConcours.toIso8601String(),
        }),
      );
      return response.statusCode == 200;
      */

      // Pour l'instant, simulation
      print('📧 Email envoyé à $candidatEmail');
      print('   Sujet: Résultat concours $typeConcours - $offreTitre');
      print('   Résultat: ${isAdmis ? "ADMIS" : "REJETÉ"}');

      return true;
    } catch (e) {
      print('Erreur envoi email: $e');
      return false;
    }
  }

  // Fonction pour marquer l'email comme reçu
  static Future<void> markEmailAsReceived({
    required String candidatureId,
    required String typeConcours,
  }) async {
    // Appel API pour mettre à jour la candidature
    print(' Email $typeConcours marqué comme reçu pour $candidatureId');
  }
}