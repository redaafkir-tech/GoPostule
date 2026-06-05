// lib/features/offres/screens/offres_saved_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/offre_service.dart';
import '../../../shared/offre.dart';
import '../../candidatures/screens/postuler_screen.dart';

class OffresSavedScreen extends StatefulWidget {
  const OffresSavedScreen({super.key});

  @override
  State<OffresSavedScreen> createState() => _OffresSavedScreenState();
}

class _OffresSavedScreenState extends State<OffresSavedScreen> {
  final _offreService = OffreService();

  List<Offre> _savedOffers = [];
  List<int> _savedIds = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSavedOffers();
  }

  // ✅ Charger les offres sauvegardées
  Future<void> _loadSavedOffers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1️⃣ Récupérer les IDs sauvegardés
      final prefs = await SharedPreferences.getInstance();
      final savedIdsStrings = prefs.getStringList('saved_offres') ?? [];
      _savedIds = savedIdsStrings.map((id) => int.parse(id)).toList();

      print('📥 IDs sauvegardés: $_savedIds');

      if (_savedIds.isEmpty) {
        setState(() {
          _savedOffers = [];
          _isLoading = false;
        });
        return;
      }

      // 2️⃣ Récupérer toutes les offres depuis l'API
      final allOffres = await _offreService.getAllOffres();

      print('📦 Total offres API: ${allOffres.length}');

      // 3️⃣ Filtrer seulement les offres sauvegardées
      setState(() {
        _savedOffers = allOffres
            .where((offre) => _savedIds.contains(offre.id))
            .toList();
        _isLoading = false;
      });

      print('✅ Offres sauvegardées affichées: ${_savedOffers.length}');
    } catch (e) {
      print('❌ Erreur chargement favoris: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ✅ Retirer des favoris
  Future<void> _removeFromFavorites(int offreId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_offres') ?? [];

    saved.remove(offreId.toString());
    await prefs.setStringList('saved_offres', saved);

    setState(() {
      _savedOffers.removeWhere((offre) => offre.id == offreId);
      _savedIds.remove(offreId);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offre retirée des favoris'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ✅ Naviguer vers postuler
  void _navigateToPostuler(Offre offre) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostulerScreen(offre: offre)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Offres sauvegardées'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_savedOffers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: _loadSavedOffers,
              tooltip: 'Rafraîchir',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadSavedOffers,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : _savedOffers.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadSavedOffers,
        color: AppColors.accent,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _savedOffers.length,
          itemBuilder: (context, index) {
            final offre = _savedOffers[index];
            return _buildOfferCard(offre);
          },
        ),
      ),
    );
  }

  Widget _buildOfferCard(Offre offre) {
    return Dismissible(
      key: Key(offre.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => _removeFromFavorites(offre.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Logo entreprise
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F2460), Color(0xFF1E40AF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      offre.entreprise.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Infos offre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offre.titre,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        offre.entreprise,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              offre.salaire ?? 'Non spécifié',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              offre.typeContrat,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Bouton favori
                IconButton(
                  icon: const Icon(Icons.favorite, color: AppColors.danger),
                  onPressed: () => _removeFromFavorites(offre.id),
                  tooltip: 'Retirer des favoris',
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Bouton Postuler
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToPostuler(offre),
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Postuler'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 80,
            color: AppColors.textGrey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune offre sauvegardée',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur ⭐ pour sauvegarder vos offres préférées',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/offres');
            },
            icon: const Icon(Icons.search_rounded),
            label: const Text('Parcourir les offres'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}