import 'dart:math';

class Formatters {
  /// Formate une taille en octets en chaîne lisible (ex: 14.50 Mo, 1.20 Go)
  static String formatBytes(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return "0.00 Mo";
    const suffixes = ["o", "Ko", "Mo", "Go", "To"];
    var i = (log(bytes) / log(1024)).floor();
    if (i >= suffixes.length) i = suffixes.length - 1;
    double size = bytes / pow(1024, i);
    return "${size.toStringAsFixed(decimals)} ${suffixes[i]}";
  }

  /// Formate une durée en millisecondes ou secondes en chaîne mm:ss ou hh:mm:ss
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  /// Calcule le pourcentage d'espace économisé
  static double calculateReductionPercentage(int originalBytes, int compressedBytes) {
    if (originalBytes <= 0) return 0.0;
    if (compressedBytes >= originalBytes) return 0.0;
    return ((originalBytes - compressedBytes) / originalBytes) * 100.0;
  }

  /// Formate le taux de réduction avec signe
  static String formatReduction(int originalBytes, int compressedBytes) {
    final reduction = calculateReductionPercentage(originalBytes, compressedBytes);
    return "-${reduction.toStringAsFixed(1)}%";
  }

  /// Calcule l'espace absolu économisé
  static String formatSavedBytes(int originalBytes, int compressedBytes) {
    final diff = originalBytes - compressedBytes;
    if (diff <= 0) return "0 Mo";
    return formatBytes(diff);
  }
}
