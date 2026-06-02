import 'package:flutter/material.dart';

enum DocumentKind { ci, oficio }

class AgendaEvent {
  const AgendaEvent({
    required this.date,
    required this.time,
    required this.title,
    required this.people,
    required this.description,
    required this.color,
    required this.tag,
    this.legalBasis = 'Execucao de politica publica',
    this.dataPurpose = 'Organizacao de agenda institucional',
    this.accessLevel = 'Participantes e usuarios autorizados',
  });

  final DateTime date;
  final String time;
  final String title;
  final String people;
  final String description;
  final Color color;
  final String tag;
  final String legalBasis;
  final String dataPurpose;
  final String accessLevel;
}

class AppDocument {
  const AppDocument({
    required this.kind,
    required this.number,
    required this.subject,
    required this.party,
    required this.status,
    required this.received,
    required this.sender,
    required this.recipient,
    required this.message,
    this.assignedSigner = 'Dra. Gabriela Santos',
    this.signedBy,
    this.signatureStatus,
    this.legalBasis = 'Execucao de politica publica',
    this.dataPurpose = 'Comunicacao oficial e tramitacao administrativa',
    this.accessLevel = 'Usuarios autorizados pelo setor',
    this.retentionPolicy = 'Retencao conforme regra administrativa',
  });

  final DocumentKind kind;
  final String number;
  final String subject;
  final String party;
  final String status;
  final bool received;
  final String sender;
  final String recipient;
  final String message;
  final String assignedSigner;
  final String? signedBy;
  final String? signatureStatus;
  final String legalBasis;
  final String dataPurpose;
  final String accessLevel;
  final String retentionPolicy;
}

class DetailItem {
  const DetailItem(this.label, this.value);

  final String label;
  final String value;
}

class AppUser {
  const AppUser({
    required this.name,
    required this.sector,
    required this.role,
    required this.email,
    required this.phone,
    required this.registration,
    required this.createdAt,
  });

  final String name;
  final String sector;
  final String role;
  final String email;
  final String phone;
  final String registration;
  final String createdAt;
}

class VisitRecord {
  const VisitRecord({
    required this.name,
    required this.document,
    required this.sector,
    required this.target,
    required this.status,
    required this.time,
    this.photoPath,
    this.visitReason = 'Atendimento presencial',
    this.lgpdAcknowledged = true,
    this.legalBasis = 'Execucao de politica publica',
    this.dataPurpose = 'Controle de acesso e atendimento presencial',
    this.denialReason,
    this.pending = false,
  });

  final String name;
  final String document;
  final String sector;
  final String target;
  final String status;
  final String time;
  final String? photoPath;
  final String visitReason;
  final bool lgpdAcknowledged;
  final String legalBasis;
  final String dataPurpose;
  final String? denialReason;
  final bool pending;

  VisitRecord copyWith({
    String? status,
    String? time,
    String? photoPath,
    String? visitReason,
    bool? lgpdAcknowledged,
    String? legalBasis,
    String? dataPurpose,
    String? denialReason,
    bool? pending,
  }) {
    return VisitRecord(
      name: name,
      document: document,
      sector: sector,
      target: target,
      status: status ?? this.status,
      time: time ?? this.time,
      photoPath: photoPath ?? this.photoPath,
      visitReason: visitReason ?? this.visitReason,
      lgpdAcknowledged: lgpdAcknowledged ?? this.lgpdAcknowledged,
      legalBasis: legalBasis ?? this.legalBasis,
      dataPurpose: dataPurpose ?? this.dataPurpose,
      denialReason: denialReason ?? this.denialReason,
      pending: pending ?? this.pending,
    );
  }
}

const _keepPhotoPath = Object();

class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.cpf,
    required this.birthDate,
    required this.email,
    required this.phone,
    required this.role,
    required this.sector,
    required this.registration,
    required this.initials,
    required this.avatarColor,
    this.photoPath,
  });

  final String fullName;
  final String cpf;
  final String birthDate;
  final String email;
  final String phone;
  final String role;
  final String sector;
  final String registration;
  final String initials;
  final Color avatarColor;
  final String? photoPath;

  UserProfile copyWith({
    String? email,
    String? phone,
    String? role,
    String? sector,
    String? registration,
    String? initials,
    Color? avatarColor,
    Object? photoPath = _keepPhotoPath,
  }) {
    return UserProfile(
      fullName: fullName,
      cpf: cpf,
      birthDate: birthDate,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      sector: sector ?? this.sector,
      registration: registration ?? this.registration,
      initials: initials ?? this.initials,
      avatarColor: avatarColor ?? this.avatarColor,
      photoPath: identical(photoPath, _keepPhotoPath)
          ? this.photoPath
          : photoPath as String?,
    );
  }
}
