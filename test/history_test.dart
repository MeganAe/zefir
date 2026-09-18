import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zefir/core/constants/app_constants.dart';
import 'package:zefir/models/compression_result.dart';
import 'package:zefir/services/history_service.dart';

/// Construction d'un enregistrement réaliste.
CompressionResult makeRecord(
  String id, {
  DateTime? createdAt,
  int original = 1_000_000,
  int compressed = 250_000,
  String fileName = 'video.mp4',
}) {
  return CompressionResult(
    id: id,
    fileName: fileName,
    originalPath: '/src/$fileName',
    compressedPath: '/out/$id.mp4',
    originalSizeBytes: original,
    compressedSizeBytes: compressed,
    durationMs: 60_000,
    presetId: 'balanced',
    presetLabel: 'Équilibré',
    createdAt: createdAt ?? DateTime(2026, 9, 1),
    executionTimeSeconds: 12,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CompressionResult sérialisation', () {
    test('round-trip toMap/fromMap conserve toutes les données', () {
      final record = makeRecord('r1', createdAt: DateTime(2026, 1, 15, 8, 30));
      final restored = CompressionResult.fromMap(record.toMap());

      expect(restored.id, 'r1');
      expect(restored.fileName, 'video.mp4');
      expect(restored.originalSizeBytes, 1_000_000);
      expect(restored.compressedSizeBytes, 250_000);
      expect(restored.createdAt, DateTime(2026, 1, 15, 8, 30));
      expect(restored.presetId, 'balanced');
      expect(restored.executionTimeSeconds, 12);
    });

    test('round-trip JSON identique', () {
      final record = makeRecord('r2');
      final restored = CompressionResult.fromJson(record.toJson());
      expect(restored.id, 'r2');
      expect(restored.savedBytes, 750_000);
    });

    test('fromMap tolère un enregistrement incomplet', () {
      final restored = CompressionResult.fromMap({'id': 'only'});
      expect(restored.id, 'only');
      expect(restored.originalSizeBytes, 0);
      expect(restored.presetId, 'balanced');
    });

    test('savedBytes et savingsPercentage bornés', () {
      final gain = makeRecord('g', original: 1000, compressed: 400);
      expect(gain.savedBytes, 600);
      expect(gain.savingsPercentage, closeTo(60.0, 0.001));

      final loss = makeRecord('l', original: 1000, compressed: 2000);
      expect(loss.savedBytes, 0);
      expect(loss.savingsPercentage, 0.0);
    });
  });

  group('HistoryService', () {
  test('addRecord persiste et recharge', () async {
    final service = HistoryService();
    await service.loadHistory();
    await service.addRecord(makeRecord('a'));

    await service.loadHistory();
    expect(service.items, hasLength(1));
    expect(service.items.first.id, 'a');
  });

  test('addRecord place le plus récent en tête', () async {
    final service = HistoryService();
    await service.loadHistory();

    await service.addRecord(
      makeRecord('old', createdAt: DateTime(2026, 1, 1)),
    );
    await service.addRecord(
      makeRecord('new', createdAt: DateTime(2026, 6, 1)),
    );

    expect(service.items.first.id, 'new');
  });

  test('deleteRecord retire sans toucher aux autres', () async {
    final service = HistoryService();
    await service.loadHistory();
    await service.addRecord(makeRecord('a'));
    await service.addRecord(makeRecord('b'));

    await service.deleteRecord('a', deleteFileFromDisk: false);
    expect(service.items.map((e) => e.id), ['b']);
  });

  test('deleteRecords en masse retourne le nombre retiré', () async {
    final service = HistoryService();
    await service.loadHistory();
    await service.addRecord(makeRecord('a'));
    await service.addRecord(makeRecord('b'));
    await service.addRecord(makeRecord('c'));

    final removed = await service.deleteRecords(
      ['a', 'c'],
      deleteFilesFromDisk: false,
    );
    expect(removed, 2);
    expect(service.items.map((e) => e.id), ['b']);
  });

  test('clearAll vide historique et stockage', () async {
    final service = HistoryService();
    await service.loadHistory();
    await service.addRecord(makeRecord('a'));

    await service.clearAll(deleteFiles: false);
    expect(service.isEmpty, isTrue);

    await service.loadHistory();
    expect(service.isEmpty, isTrue);
  });

  test('search filtre par nom et libellé de profil', () async {
    final service = HistoryService();
    await service.loadHistory();
    await service.addRecord(makeRecord('a', fileName: 'vacances.mp4'));
    await service.addRecord(makeRecord('b', fileName: 'reunion.mp4'));

    expect(service.search('vacances').map((e) => e.id), ['a']);
    expect(service.search('ÉQUILIBRÉ'), hasLength(2));
    expect(service.search(''), hasLength(2));
  });

  test('byId retrouve ou retourne null', () async {
    final service = HistoryService();
    await service.loadHistory();
    await service.addRecord(makeRecord('x'));

    expect(service.byId('x'), isNotNull);
    expect(service.byId('y'), isNull);
  });

  test('statistiques agrégées cohérentes', () async {
    final service = HistoryService();
    await service.loadHistory();
    await service.addRecord(
      makeRecord('a', original: 1000, compressed: 500),
    );
    await service.addRecord(
      makeRecord('b', original: 3000, compressed: 1000),
    );

    expect(service.totalVideosCompressed, 2);
    expect(service.totalOriginalBytes, 4000);
    expect(service.totalCompressedBytes, 1500);
    expect(service.totalSavedBytes, 2500);
    expect(service.averageReduction, closeTo(62.5, 0.001));
  });

  test('sort applique les critères AppConstants', () {
    final records = [
      makeRecord('c', createdAt: DateTime(2026, 3, 1)),
      makeRecord('a', createdAt: DateTime(2026, 1, 1), compressed: 900),
      makeRecord('b', createdAt: DateTime(2026, 2, 1), compressed: 100),
    ];

    expect(
      HistoryService.sort(records, AppConstants.sortByDateDesc)
          .map((e) => e.id),
      ['c', 'b', 'a'],
    );
    expect(
      HistoryService.sort(records, AppConstants.sortByDateAsc).map((e) => e.id),
      ['a', 'b', 'c'],
    );
    expect(
      HistoryService.sort(records, AppConstants.sortBySize).map((e) => e.id),
      ['a', 'c', 'b'],
    );
    expect(
      HistoryService.sort(records, AppConstants.sortBySavings).map((e) => e.id),
      ['b', 'a', 'c'],
    );
  });

  test('tolère un JSON corrompu lors du chargement', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.historyStorageKey, [
      makeRecord('ok').toJson(),
      '{json invalide',
    ]);

    final service = HistoryService();
    await service.loadHistory();

    expect(service.items, hasLength(1));
    expect(service.items.first.id, 'ok');
    expect(service.isLoaded, isTrue);
  });
});
