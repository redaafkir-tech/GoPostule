// lib/features/notifications/screens/notifications_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // 🎯 DONNÉES DE TEST (À remplacer par l'API)
  List<Map<String, dynamic>> _notifications = [
    {
      'id': 1,
      'titre': 'Candidature reçue',
      'message': 'Votre candidature pour "Ingénieur Génie Logiciel" a bien été enregistrée.',
      'type': 'success', // info, success, warning, error
      'date': 'Il y a 2 heures',
      'lu': false,
    },
    {
      'id': 2,
      'titre': 'Convocation entretien',
      'message': 'Vous êtes convoqué pour un entretien technique le 28 Mai à 10h00.',
      'type': 'warning',
      'date': 'Hier',
      'lu': false,
    },
    {
      'id': 3,
      'titre': 'Profil mis à jour',
      'message': 'Votre CV a été mis à jour avec succès.',
      'type': 'info',
      'date': 'Il y a 3 jours',
      'lu': true,
    },
    {
      'id': 4,
      'titre': 'Offre expirée',
      'message': 'L\'offre "Stagiaire Data" n\'est plus disponible.',
      'type': 'error',
      'date': 'Il y a 1 semaine',
      'lu': true,
    },
  ];

  Color _getTypeColor(String type) {
    switch (type) {
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.accent;
      case 'error':
        return AppColors.danger;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'error':
        return Icons.error_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  void _markAsRead(int id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) _notifications[index]['lu'] = true;
    });
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !(n['lu'] as bool)).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all_rounded, color: Colors.white),
              tooltip: 'Tout marquer comme lu',
              onPressed: () {
                setState(() {
                  _notifications.forEach((n) => n['lu'] = true);
                });
              },
            ),
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
              tooltip: 'Tout effacer',
              onPressed: _clearAll,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : Column(
        children: [
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: AppColors.accent.withOpacity(0.1),
              child: Center(
                child: Text(
                  '$unreadCount notification${unreadCount > 1 ? 's' : ''} non lue${unreadCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                return _buildNotificationItem(notif);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notif) {
    final typeColor = _getTypeColor(notif['type']);
    final isUnread = !(notif['lu'] as bool);

    return GestureDetector(
      onTap: () => _markAsRead(notif['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread ? typeColor.withOpacity(0.2) : Colors.transparent,
            width: isUnread ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getTypeIcon(notif['type']),
                color: typeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        notif['titre'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: typeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif['message'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notif['date'],
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey.withOpacity(0.7),
                    ),
                  ),
                ],
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
            Icons.notifications_none_rounded,
            size: 80,
            color: AppColors.textGrey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune notification',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vous serez notifié des mises à jour de vos candidatures',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}