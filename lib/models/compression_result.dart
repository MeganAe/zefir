import 'dart:convert';

class CompressionResult {
  final String id;
  final String fileName;
  final String originalPath;
  final String compressedPath;
  final int originalSizeBytes;
  final int compressedSizeBytes;
  final int durationMs;
  final String presetId;
  final String presetLabel;
  final DateTime createdAt;
  final int executionTimeSeconds;

  const CompressionResult({
    required this.id,
    required this.fileName,
    required this.originalPath,
    required this.compressedPath,
    required this.originalSizeBytes,
    required this.compressedSizeBytes,
    required this.durationMs,
    required this.presetId,
    required this.presetLabel,
    required this.createdAt,
    required this.executionTimeSeconds,
  });

  int get savedBytes => originalSizeBytes > compressedSizeBytes ? originalSizeBytes - compressedSizeBytes : 0;

  double get savingsPercentage {
    if (originalSizeBytes <= 0) return 0.0;
    if (compressedSizeBytes >= originalSizeBytes) return 0.0;
    return ((originalSizeBytes - compressedSizeBytes) / originalSizeBytes) * 100.0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'originalPath': originalPath,
      'compressedPath': compressedPath,
      'originalSizeBytes': originalSizeBytes,
      'compressedSizeBytes': compressedSizeBytes,
      'durationMs': durationMs,
      'presetId': presetId,
      'presetLabel': presetLabel,
      'createdAt': createdAt.toIso8601String(),
      'executionTimeSeconds': executionTimeSeconds,
    };
  }

  factory CompressionResult.fromMap(Map<String, dynamic> map) {
    return CompressionResult(
      id: map['id'] ?? '',
      fileName: map['fileName'] ?? '',
      originalPath: map['originalPath'] ?? '',
      compressedPath: map['compressedPath'] ?? '',
      originalSizeBytes: map['originalSizeBytes'] ?? 0,
      compressedSizeBytes: map['compressedSizeBytes'] ?? 0,
      durationMs: map['durationMs'] ?? 0,
      presetId: map['presetId'] ?? 'balanced',
      presetLabel: map['presetLabel'] ?? 'Standard',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      executionTimeSeconds: map['executionTimeSeconds'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory CompressionResult.fromJson(String source) => CompressionResult.fromMap(json.decode(source));
}
