import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_models.dart';
import 'mock_data_service.dart';

class LocalDataStore {
  static const _eventsKey = 'sistema_gerir.events.v1';
  static const _documentsKey = 'sistema_gerir.documents.v1';
  static const _visitsKey = 'sistema_gerir.visits.v1';

  Future<PersistedAppData> load(MockDataService mockData) async {
    final preferences = await SharedPreferences.getInstance();
    return PersistedAppData(
      events: _readList(
        preferences,
        _eventsKey,
        AgendaEvent.fromJson,
        mockData.initialEvents,
      ),
      documents: _readList(
        preferences,
        _documentsKey,
        AppDocument.fromJson,
        mockData.initialDocuments,
      ),
      visits: _readList(
        preferences,
        _visitsKey,
        VisitRecord.fromJson,
        mockData.initialVisits,
      ),
    );
  }

  Future<void> save({
    required List<AgendaEvent> events,
    required List<AppDocument> documents,
    required List<VisitRecord> visits,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setString(
        _eventsKey,
        jsonEncode(events.map((event) => event.toJson()).toList()),
      ),
      preferences.setString(
        _documentsKey,
        jsonEncode(documents.map((document) => document.toJson()).toList()),
      ),
      preferences.setString(
        _visitsKey,
        jsonEncode(visits.map((visit) => visit.toJson()).toList()),
      ),
    ]);
  }

  List<T> _readList<T>(
    SharedPreferences preferences,
    String key,
    T Function(Map<String, dynamic> json) fromJson,
    List<T> Function() fallback,
  ) {
    final raw = preferences.getString(key);
    if (raw == null || raw.isEmpty) return List.of(fallback());
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(growable: true);
    } catch (_) {
      return List.of(fallback());
    }
  }
}

class PersistedAppData {
  const PersistedAppData({
    required this.events,
    required this.documents,
    required this.visits,
  });

  final List<AgendaEvent> events;
  final List<AppDocument> documents;
  final List<VisitRecord> visits;
}
