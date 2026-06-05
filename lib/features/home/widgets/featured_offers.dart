// lib/features/home/widgets/featured_offers.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FeaturedOffers extends StatelessWidget {
  const FeaturedOffers({super.key});

  // Couleurs directes
  static const Color _primary = Color(0xFF0D1B3E);
  static const Color _accent = Color(0xFFF5C518);
  static const _textGrey = Color(0xFF757575);
  static const _textDark = Color(0xFF0D1B3E);
  static const _statusReview = Color(0xFF1565C0);
  static const _statusOffer = Color(0xFF43A047);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _statusReview.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.work_outline,
                      color: _statusReview,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Offres recommandées',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/offres'),
                child: const Text(
                  'Voir tout',
                  style: TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _OfferCard(
            company: 'ONEE',
            title: 'Ingénieur Génie Logiciel',
            location: 'Rabat',
            salary: '8000 - 12000 MAD',
            type: 'CDI',
          ),
          const SizedBox(height: 12),
          _OfferCard(
            company: 'Maroc Telecom',
            title: 'Développeur Full Stack',
            location: 'Casablanca',
            salary: '7000 - 10000 MAD',
            type: 'CDI',
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final String company;
  final String title;
  final String location;
  final String salary;
  final String type;

  const _OfferCard({
    required this.company,
    required this.title,
    required this.location,
    required this.salary,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FeaturedOffers._accent.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: FeaturedOffers._primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.business, color: FeaturedOffers._primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: FeaturedOffers._textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    company,
                    style: const TextStyle(fontSize: 12, color: FeaturedOffers._textGrey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _Badge(icon: Icons.location_on, text: location),
                      const SizedBox(width: 8),
                      _Badge(icon: Icons.attach_money, text: salary),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: FeaturedOffers._statusOffer.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          type,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: FeaturedOffers._statusOffer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: FeaturedOffers._accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.bookmark_border,
                color: FeaturedOffers._accent,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Badge({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: FeaturedOffers._textGrey),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, color: FeaturedOffers._textGrey)),
      ],
    );
  }
}