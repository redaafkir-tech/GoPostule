// lib/features/navigation/main_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/offres/screens/offres_screen.dart';
import '../../features/candidatures/screens/candidatures_screen.dart';
import '../../features/auth/screens/profil_screen.dart';
import 'quick_actions_sheet.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // ✅ Couleurs directes
  static const Color _primary = Color(0xFF0D1B3E);
  static const Color _accent = Color(0xFFF5C518);
  static const Color _textLight = Color(0xFFFFFFFF);

  final List<Widget> _pages = [
    const HomeScreen(),
    const OffresScreen(),
    Container(), // Placeholder pour le bouton +
    const CandidaturesScreen(),
    const ProfilScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // ✅ Bouton + : Ouvrir Quick Actions
      HapticFeedback.mediumImpact();
      _showQuickActions();
      return;
    }

    HapticFeedback.lightImpact();
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return const QuickActionsSheet();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex == 2 ? 0 : _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: _primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex == 2 ? 0 : _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: _accent,
            unselectedItemColor: _textLight.withOpacity(0.7),
            selectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Accueil',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.work_outline),
                activeIcon: Icon(Icons.work_rounded),
                label: 'Offres',
              ),
              // ✅ BOUTON + CENTRAL PREMIUM
              BottomNavigationBarItem(
                icon: _buildCenterButton(),
                label: '',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.folder_outlined),
                activeIcon: Icon(Icons.folder_rounded),
                label: 'Candidatures',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ WIDGET BOUTON + PREMIUM
  Widget _buildCenterButton() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [_accent, Color(0xFFD4A574)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [_accent, Color(0xFFE5B98C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(
            Icons.add_rounded,
            color: _primary,
            size: 32,
          ),
        ),
      ),
    );
  }
}