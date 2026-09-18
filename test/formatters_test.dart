import 'package:flutter_test/flutter_test.dart';
import 'package:zefir/core/utils/formatters.dart';

void main() {
  group('Formatters.formatBytes', () {
    test('gère les valeurs nulles et négatives', () {
      expect(Formatters.formatBytes(0), '0.00 Mo');
      expect(Formatters.formatBytes(-120), '0.00 Mo');
    });

    test('affiche les octets et kilo-octets', () {
      expect(Formatters.formatBytes(750), '750.00 o');
      expect(Formatters.formatBytes(1024), '1.00 Ko');
      expect(Formatters.formatBytes(1536), '1.50 Ko');
    });

    test('affiche les méga et gigaoctets', () {
      expect(Formatters.formatBytes(1048576), '1.00 Mo');
      expect(Formatters.formatBytes(1073741824), '1.00 Go');
    });

    test('respecte le nombre de décimales demandé', () {
      expect(Formatters.formatBytes(1048576, 1), '1.0 Mo');
    });
  });

  group('Formatters.formatDuration', () {
    test('formate mm:ss sous une heure', () {
      expect(Formatters.formatDuration(const Duration(seconds: 5)), '00:05');
      expect(
        Formatters.formatDuration(const Duration(minutes: 1, seconds: 5)),
        '01:05',
      );
    });

    test('formate hh:mm:ss au-delà d\'une heure', () {
      expect(Formatters.formatDuration(const Duration(hours: 2)), '02:00:00');
      expect(
        Formatters.formatDuration(
            const Duration(hours: 1, minutes: 2, seconds: 3)),
        '01:02:03',
      );
    });
  });

  group('Formatters réduction', () {
    test('calculateReductionPercentage calcule le gain', () {
      expect(
        Formatters.calculateReductionPercentage(1000, 250),
        closeTo(75.0, 0.001),
      );
    });

    test('retourne 0 pour les cas dégénérés', () {
      expect(Formatters.calculateReductionPercentage(0, 0), 0.0);
      expect(Formatters.calculateReductionPercentage(1000, 1000), 0.0);
      expect(Formatters.calculateReductionPercentage(1000, 2000), 0.0);
      expect(Formatters.calculateReductionPercentage(-100, -50), 0.0);
    });

    test('formatReduction inclut le signe', () {
      expect(Formatters.formatReduction(1000, 250), '-75.0%');
    });

    test('formatSavedBytes retourne 0 Mo sans gain', () {
      expect(Formatters.formatSavedBytes(1000, 1000), '0 Mo');
      expect(Formatters.formatSavedBytes(1000, 250), '750.00 o');
    });
  });
}
