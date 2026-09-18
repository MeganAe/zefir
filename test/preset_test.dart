import 'package:flutter_test/flutter_test.dart';
import 'package:zefir/models/compression_preset.dart';

void main() {
  group('CompressionPreset.allPresets', () {
    test('contient 4 profils avec identifiants uniques', () {
      expect(CompressionPreset.allPresets, hasLength(4));
      final ids = CompressionPreset.allPresets.map((p) => p.id).toSet();
      expect(ids, hasLength(4));
    });

    test('le profil par défaut est "balanced"', () {
      expect(CompressionPreset.defaultPreset.id, 'balanced');
    });

    test('getById retombe sur le profil par défaut', () {
      expect(CompressionPreset.getById('inexistant').id, 'balanced');
      expect(CompressionPreset.getById('archival').id, 'archival');
    });
  });

  group('CompressionPreset.buildArgs', () {
    test('construit un pipeline x264/aac valide', () {
      final args = CompressionPreset.defaultPreset
          .buildArgs('/input.mp4', '/output.mp4');

      expect(args.first, '-y');
      expect(args, containsAllInOrder(<String>['-i', '/input.mp4']));
      expect(args.last, '/output.mp4');

      final crfIndex = args.indexOf('-crf');
      expect(crfIndex, greaterThanOrEqualTo(0));
      expect(args[crfIndex + 1], '26');

      final presetIndex = args.indexOf('-preset');
      expect(args[presetIndex + 1], 'medium');

      final audioIndex = args.indexOf('-b:a');
      expect(args[audioIndex + 1], '128k');

      expect(args, contains('-c:v'));
      expect(args, contains('libx264'));
      expect(args, contains('aac'));
      expect(args, contains('+faststart'));
    });

    test('applique le filtre d\'échelle quand il est défini', () {
      final args = CompressionPreset.defaultPreset.buildArgs('a', 'b');
      final vfIndex = args.indexOf('-vf');
      expect(vfIndex, greaterThanOrEqualTo(0));
      expect(args[vfIndex + 1], contains('scale='));
    });

    test('n\'applique pas de filtre pour la haute fidélité', () {
      final hq = CompressionPreset.getById('high_quality');
      expect(hq.scaleFilter, isNull);
      final args = hq.buildArgs('a', 'b');
      expect(args.contains('-vf'), isFalse);
    });

    test('hwaccelDecode insère -hwaccel auto avant -i', () {
      final args = CompressionPreset.defaultPreset.buildArgs('a', 'b',
          hwaccelDecode: true);
      final hwIndex = args.indexOf('-hwaccel');
      final iIndex = args.indexOf('-i');
      expect(hwIndex, greaterThanOrEqualTo(0));
      expect(args[hwIndex + 1], 'auto');
      expect(hwIndex, lessThan(iIndex));
    });

    test('sans hwaccel, aucun -hwaccel', () {
      final args = CompressionPreset.defaultPreset.buildArgs('a', 'b');
      expect(args.contains('-hwaccel'), isFalse);
    });
  });

  group('CompressionPreset.withTargetHeight', () {
    test('écrase la hauteur cible des profils scalés', () {
      final adjusted =
          CompressionPreset.getById('balanced').withTargetHeight(480);
      expect(adjusted.scaleFilter, contains('480'));
    });

    test('laisse la haute fidélité à la résolution source', () {
      final hq = CompressionPreset.getById('high_quality');
      expect(hq.withTargetHeight(480).scaleFilter, isNull);
    });

    test('conserve les autres attributs', () {
      final adjusted =
          CompressionPreset.getById('ultra_light').withTargetHeight(1080);
      expect(adjusted.id, 'ultra_light');
      expect(adjusted.crf, 30);
      expect(adjusted.audioBitrate, '96k');
      expect(adjusted.presetSpeed, 'fast');
    });
  });

  group('CompressionPreset.withAudioBitrate', () {
    test('remplace le débit audio', () {
      final adjusted = CompressionPreset.getById('balanced').withAudioBitrate(96);
      expect(adjusted.audioBitrate, '96k');
    });

    test('ignore une valeur non positive', () {
      final original = CompressionPreset.getById('balanced');
      expect(original.withAudioBitrate(0).audioBitrate, original.audioBitrate);
      expect(original.withAudioBitrate(-5).audioBitrate, original.audioBitrate);
    });
  });
}
