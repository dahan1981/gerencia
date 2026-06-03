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

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'time': time,
      'title': title,
      'people': people,
      'description': description,
      'color': color.toARGB32(),
      'tag': tag,
      'legalBasis': legalBasis,
      'dataPurpose': dataPurpose,
      'accessLevel': accessLevel,
    };
  }

  factory AgendaEvent.fromJson(Map<String, dynamic> json) {
    return AgendaEvent(
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String? ?? '',
      title: json['title'] as String? ?? '',
      people: json['people'] as String? ?? '',
      description: json['description'] as String? ?? '',
      color: Color(json['color'] as int? ?? 0xFFD4537E),
      tag: json['tag'] as String? ?? 'Interno',
      legalBasis:
          json['legalBasis'] as String? ?? 'Execucao de politica publica',
      dataPurpose: json['dataPurpose'] as String? ??
          'Organizacao de agenda institucional',
      accessLevel: json['accessLevel'] as String? ??
          'Participantes e usuarios autorizados',
    );
  }
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

  Map<String, dynamic> toJson() {
    return {
      'kind': kind.name,
      'number': number,
      'subject': subject,
      'party': party,
      'status': status,
      'received': received,
      'sender': sender,
      'recipient': recipient,
      'message': message,
      'assignedSigner': assignedSigner,
      'signedBy': signedBy,
      'signatureStatus': signatureStatus,
      'legalBasis': legalBasis,
      'dataPurpose': dataPurpose,
      'accessLevel': accessLevel,
      'retentionPolicy': retentionPolicy,
    };
  }

  factory AppDocument.fromJson(Map<String, dynamic> json) {
    final kindName = json['kind'] as String? ?? DocumentKind.ci.name;
    return AppDocument(
      kind: DocumentKind.values.firstWhere(
        (kind) => kind.name == kindName,
        orElse: () => DocumentKind.ci,
      ),
      number: json['number'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      party: json['party'] as String? ?? '',
      status: json['status'] as String? ?? 'Pendente',
      received: json['received'] as bool? ?? false,
      sender: json['sender'] as String? ?? '',
      recipient: json['recipient'] as String? ?? '',
      message: json['message'] as String? ?? '',
      assignedSigner:
          json['assignedSigner'] as String? ?? 'Dra. Gabriela Santos',
      signedBy: json['signedBy'] as String?,
      signatureStatus: json['signatureStatus'] as String?,
      legalBasis:
          json['legalBasis'] as String? ?? 'Execucao de politica publica',
      dataPurpose: json['dataPurpose'] as String? ??
          'Comunicacao oficial e tramitacao administrativa',
      accessLevel:
          json['accessLevel'] as String? ?? 'Usuarios autorizados pelo setor',
      retentionPolicy: json['retentionPolicy'] as String? ??
          'Retencao conforme regra administrativa',
    );
  }
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'document': document,
      'sector': sector,
      'target': target,
      'status': status,
      'time': time,
      'photoPath': photoPath,
      'visitReason': visitReason,
      'lgpdAcknowledged': lgpdAcknowledged,
      'legalBasis': legalBasis,
      'dataPurpose': dataPurpose,
      'denialReason': denialReason,
      'pending': pending,
    };
  }

  factory VisitRecord.fromJson(Map<String, dynamic> json) {
    return VisitRecord(
      name: json['name'] as String? ?? '',
      document: json['document'] as String? ?? '',
      sector: json['sector'] as String? ?? '',
      target: json['target'] as String? ?? '',
      status: json['status'] as String? ?? 'Aguardando',
      time: json['time'] as String? ?? '',
      photoPath: json['photoPath'] as String?,
      visitReason: json['visitReason'] as String? ?? 'Atendimento presencial',
      lgpdAcknowledged: json['lgpdAcknowledged'] as bool? ?? true,
      legalBasis:
          json['legalBasis'] as String? ?? 'Execucao de politica publica',
      dataPurpose: json['dataPurpose'] as String? ??
          'Controle de acesso e atendimento presencial',
      denialReason: json['denialReason'] as String?,
      pending: json['pending'] as bool? ?? false,
    );
  }

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
