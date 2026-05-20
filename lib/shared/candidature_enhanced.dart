// lib/shared/candidature_enhanced.dart
import 'offre.dart';

enum CandidatureStatus {
  soumise,
  examenRh,
  concoursEcrit,
  concoursOral,
  admise,
  rejetee,
}

enum ConcoursResult {
  enAttente,
  admis,
  rejete,
}

class CandidatureEnhanced {
  final String id;
  final Offre offre;
  final CandidatureStatus status;
  final DateTime dateSoumission;
  final DateTime? derniereMiseAJour;
  final int progressPercent;
  final String? phaseActuelle;
  final List<TimelineEvent> timeline;
  final DocumentStatus documentStatus;
  final InsightsData insights;
  final RecruiterInfo? recruiterInfo;
  final String? feedback;
  final DateTime? dateReponse;
  final ConcoursResult? resultatConcoursEcrit;
  final ConcoursResult? resultatConcoursOral;
  final bool emailConcoursEcritRecu;
  final bool emailConcoursOralRecu;
  final DateTime? dateConcoursEcrit;
  final DateTime? dateConcoursOral;

  CandidatureEnhanced({
    required this.id,
    required this.offre,
    required this.status,
    required this.dateSoumission,
    this.derniereMiseAJour,
    required this.progressPercent,
    this.phaseActuelle,
    required this.timeline,
    required this.documentStatus,
    required this.insights,
    this.recruiterInfo,
    this.feedback,
    this.dateReponse,
    this.resultatConcoursEcrit,
    this.resultatConcoursOral,
    this.emailConcoursEcritRecu = false,
    this.emailConcoursOralRecu = false,
    this.dateConcoursEcrit,
    this.dateConcoursOral,
  });

  factory CandidatureEnhanced.fromJson(Map<String, dynamic> json) {
    return CandidatureEnhanced(
      id: json['id'] ?? '',
      offre: Offre.fromJson(json['offre'] ?? {}),
      status: _mapStatus(json['status'] ?? 'soumise'),
      dateSoumission: json['dateSoumission'] != null
          ? DateTime.parse(json['dateSoumission'])
          : DateTime.now(),
      derniereMiseAJour: json['derniereMiseAJour'] != null
          ? DateTime.parse(json['derniereMiseAJour'])
          : null,
      progressPercent: json['progressPercent'] ?? 0,
      phaseActuelle: json['phaseActuelle'],
      timeline: (json['timeline'] as List<dynamic>?)
          ?.map((e) => TimelineEvent.fromJson(e))
          .toList() ??
          [],
      documentStatus: DocumentStatus.fromJson(json['documentStatus'] ?? {}),
      insights: InsightsData.fromJson(json['insights'] ?? {}),
      recruiterInfo: json['recruiterInfo'] != null
          ? RecruiterInfo.fromJson(json['recruiterInfo'])
          : null,
      feedback: json['feedback'],
      dateReponse: json['dateReponse'] != null
          ? DateTime.parse(json['dateReponse'])
          : null,
      resultatConcoursEcrit: json['resultatConcoursEcrit'] != null
          ? _mapConcoursResult(json['resultatConcoursEcrit'])
          : null,
      resultatConcoursOral: json['resultatConcoursOral'] != null
          ? _mapConcoursResult(json['resultatConcoursOral'])
          : null,
      emailConcoursEcritRecu: json['emailConcoursEcritRecu'] ?? false,
      emailConcoursOralRecu: json['emailConcoursOralRecu'] ?? false,
      dateConcoursEcrit: json['dateConcoursEcrit'] != null
          ? DateTime.parse(json['dateConcoursEcrit'])
          : null,
      dateConcoursOral: json['dateConcoursOral'] != null
          ? DateTime.parse(json['dateConcoursOral'])
          : null,
    );
  }

  static CandidatureStatus _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'examen_rh':
        return CandidatureStatus.examenRh;
      case 'concours_ecrit':
        return CandidatureStatus.concoursEcrit;
      case 'concours_oral':
        return CandidatureStatus.concoursOral;
      case 'admise':
        return CandidatureStatus.admise;
      case 'rejetee':
        return CandidatureStatus.rejetee;
      default:
        return CandidatureStatus.soumise;
    }
  }

  static ConcoursResult _mapConcoursResult(String result) {
    switch (result.toLowerCase()) {
      case 'admis':
        return ConcoursResult.admis;
      case 'rejete':
        return ConcoursResult.rejete;
      default:
        return ConcoursResult.enAttente;
    }
  }

  String getStatusLabel() {
    switch (status) {
      case CandidatureStatus.examenRh:
        return 'Examen RH';
      case CandidatureStatus.concoursEcrit:
        return 'Concours Écrit';
      case CandidatureStatus.concoursOral:
        return 'Concours Oral';
      case CandidatureStatus.admise:
        return 'Acceptée';
      case CandidatureStatus.rejetee:
        return 'Rejetée';
      default:
        return 'Soumise';
    }
  }
}

class TimelineEvent {
  final String phase;
  final String label;
  final DateTime date;
  final String? commentaire;
  final bool isCompleted;
  final bool isCurrent;

  TimelineEvent({
    required this.phase,
    required this.label,
    required this.date,
    this.commentaire,
    required this.isCompleted,
    required this.isCurrent,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      phase: json['phase'] ?? '',
      label: json['label'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      commentaire: json['commentaire'],
      isCompleted: json['isCompleted'] ?? false,
      isCurrent: json['isCurrent'] ?? false,
    );
  }
}

class DocumentStatus {
  final bool cvUploaded;
  final bool cinUploaded;
  final bool diplomeUploaded;
  final bool photoUploaded;
  final bool lettreMotivationUploaded;
  final int totalDocuments;
  final int uploadedDocuments;
  final int progressPercent;

  DocumentStatus({
    required this.cvUploaded,
    required this.cinUploaded,
    required this.diplomeUploaded,
    required this.photoUploaded,
    required this.lettreMotivationUploaded,
    required this.totalDocuments,
    required this.uploadedDocuments,
    required this.progressPercent,
  });

  factory DocumentStatus.fromJson(Map<String, dynamic> json) {
    final uploaded = [
      json['cvUploaded'] ?? false,
      json['cinUploaded'] ?? false,
      json['diplomeUploaded'] ?? false,
      json['photoUploaded'] ?? false,
      json['lettreMotivationUploaded'] ?? false,
    ].where((x) => x).length;

    return DocumentStatus(
      cvUploaded: json['cvUploaded'] ?? false,
      cinUploaded: json['cinUploaded'] ?? false,
      diplomeUploaded: json['diplomeUploaded'] ?? false,
      photoUploaded: json['photoUploaded'] ?? false,
      lettreMotivationUploaded: json['lettreMotivationUploaded'] ?? false,
      totalDocuments: 5,
      uploadedDocuments: uploaded,
      progressPercent: ((uploaded / 5) * 100).round(),
    );
  }

  List<String> get missingDocuments {
    final missing = <String>[];
    if (!cvUploaded) missing.add('CV');
    if (!cinUploaded) missing.add('CIN');
    if (!diplomeUploaded) missing.add('Diplôme');
    if (!photoUploaded) missing.add('Photo');
    if (!lettreMotivationUploaded) missing.add('Lettre');
    return missing;
  }
}

class InsightsData {
  final int profileCompleteness;
  final String? chancesEstimation;
  final List<String> tips;
  final String? estimatedResponseTime;
  final int candidatsConcurrents;
  final List<String> missingDocuments;

  InsightsData({
    required this.profileCompleteness,
    this.chancesEstimation,
    required this.tips,
    this.estimatedResponseTime,
    required this.candidatsConcurrents,
    this.missingDocuments = const [],
  });

  factory InsightsData.fromJson(Map<String, dynamic> json) {
    return InsightsData(
      profileCompleteness: json['profileCompleteness'] ?? 0,
      chancesEstimation: json['chancesEstimation'],
      tips: json['tips'] != null ? List<String>.from(json['tips']) : [],
      candidatsConcurrents: json['candidatsConcurrents'] ?? 0,
      estimatedResponseTime: json['estimatedResponseTime'],
      missingDocuments: json['missingDocuments'] != null
          ? List<String>.from(json['missingDocuments'])
          : [],
    );
  }
}

class RecruiterInfo {
  final String? name;
  final String? department;
  final bool isActive;
  final DateTime? lastSeen;

  RecruiterInfo({
    this.name,
    this.department,
    required this.isActive,
    this.lastSeen,
  });

  factory RecruiterInfo.fromJson(Map<String, dynamic> json) {
    return RecruiterInfo(
      name: json['name'],
      department: json['department'],
      isActive: json['isActive'] ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
    );
  }
}