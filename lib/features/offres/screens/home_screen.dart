import 'package:flutter/material.dart';
import 'package:gopostule/features/auth/screens/profil_screen.dart';
import 'package:gopostule/features/candidatures/screens/candidatures_screen.dart' hide CandidaturesScreen;
import '../../../features/offres/screens/offres_screen.dart';
import '../../offres/screens/offres_screen.dart';
import '../../candidatures/screens/candidatures_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Index de la page active dans la BottomNavigationBar
  int _currentIndex = 0;

  // Les 4 pages de la navbar — on les remplira une par une
  final List<Widget> _pages = [
    const OffresScreen(),
    const CandidaturesScreen(),
    const _DossierPage(),
    const ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body affiche la page selon l'index sélectionné
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Offres',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Candidatures',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Dossier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// Pages temporaires — placeholders jusqu'à ce qu'on les code vraiment
class _OffresPage extends StatelessWidget {
  const _OffresPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offres')),
      body: const Center(
        child: Text('Liste des offres — bientôt'),
      ),
    );
  }
}

class _CandidaturesPage extends StatelessWidget {
  const _CandidaturesPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Candidatures')),
      body: const Center(
        child: Text('Mes candidatures — bientôt'),
      ),
    );
  }
}

class _DossierPage extends StatelessWidget {
  const _DossierPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Dossier')),
      body: const Center(
        child: Text('Mon dossier — bientôt'),
      ),
    );
  }
}

class _ProfilPage extends StatelessWidget {
  const _ProfilPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          // Bouton déconnexion
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Profil — bientôt'),
      ),
    );
  }
}