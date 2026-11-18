import 'dart:math' as math;

/// Descriptive statistics for a single variable.
class Stats1 {
  final List<double> values;
  const Stats1(this.values);

  int get count => values.length;
  double get sum => values.fold(0.0, (a, b) => a + b);
  double get mean => count == 0 ? double.nan : sum / count;

  /// Population standard deviation (σn).
  double get sigma {
    if (count == 0) return double.nan;
    final mu = mean;
    final variance =
        values.fold(0.0, (a, v) => a + (v - mu) * (v - mu)) / count;
    return math.sqrt(variance);
  }

  /// Sample standard deviation (s), using n-1.
  double get sampleSigma {
    if (count < 2) return double.nan;
    final mu = mean;
    final variance =
        values.fold(0.0, (a, v) => a + (v - mu) * (v - mu)) / (count - 1);
    return math.sqrt(variance);
  }

  double get min => values.isEmpty ? double.nan : values.reduce(math.min);
  double get max => values.isEmpty ? double.nan : values.reduce(math.max);

  double get median {
    if (values.isEmpty) return double.nan;
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[mid]
        : (sorted[mid - 1] + sorted[mid]) / 2;
  }

  /// Lower and upper quartiles (inclusive of the median for odd counts).
  (double, double) get quartiles {
    if (values.isEmpty) return (double.nan, double.nan);
    final sorted = [...values]..sort();
    return (_percentile(sorted, 0.25), _percentile(sorted, 0.75));
  }

  static double _percentile(List<double> sorted, double p) {
    if (sorted.length == 1) return sorted.first;
    final pos = p * (sorted.length - 1);
    final lo = pos.floor();
    final hi = pos.ceil();
    if (lo == hi) return sorted[lo];
    return sorted[lo] + (sorted[hi] - sorted[lo]) * (pos - lo);
  }
}

/// Descriptive statistics and regression for paired variables.
class Stats2 {
  final List<double> xs;
  final List<double> ys;
  const Stats2(this.xs, this.ys)
      : assert(xs.length == ys.length, 'x and y must have equal length');

  int get count => xs.length;

  double get meanX => count == 0 ? double.nan : xs.fold(0.0, (a, b) => a + b) / count;
  double get meanY => count == 0 ? double.nan : ys.fold(0.0, (a, b) => a + b) / count;

  double get sumX => xs.fold(0.0, (a, b) => a + b);
  double get sumY => ys.fold(0.0, (a, b) => a + b);
  double get sumXY {
    var s = 0.0;
    for (var i = 0; i < count; i++) {
      s += xs[i] * ys[i];
    }
    return s;
  }

  double get sumX2 => xs.fold(0.0, (a, b) => a + b * b);
  double get sumY2 => ys.fold(0.0, (a, b) => a + b * b);

  double get sigmaX {
    if (count == 0) return double.nan;
    final mu = meanX;
    final v = xs.fold(0.0, (a, x) => a + (x - mu) * (x - mu)) / count;
    return math.sqrt(v);
  }

  double get sigmaY {
    if (count == 0) return double.nan;
    final mu = meanY;
    final v = ys.fold(0.0, (a, y) => a + (y - mu) * (y - mu)) / count;
    return math.sqrt(v);
  }

  double get sampleSigmaX {
    if (count < 2) return double.nan;
    final mu = meanX;
    final v = xs.fold(0.0, (a, x) => a + (x - mu) * (x - mu)) / (count - 1);
    return math.sqrt(v);
  }

  double get sampleSigmaY {
    if (count < 2) return double.nan;
    final mu = meanY;
    final v = ys.fold(0.0, (a, y) => a + (y - mu) * (y - mu)) / (count - 1);
    return math.sqrt(v);
  }

  /// Pearson correlation coefficient r.
  double get correlation {
    if (count < 2) return double.nan;
    final dx = xs.fold(0.0, (a, x) => a + (x - meanX) * (x - meanX));
    final dy = ys.fold(0.0, (a, y) => a + (y - meanY) * (y - meanY));
    var dxy = 0.0;
    for (var i = 0; i < count; i++) {
      dxy += (xs[i] - meanX) * (ys[i] - meanY);
    }
    final denom = math.sqrt(dx * dy);
    if (denom == 0) return double.nan;
    return dxy / denom;
  }

  /// Linear regression `y = a + b x`.
  (double, double) get regressionYX {
    if (count < 2) return (double.nan, double.nan);
    final denom = sumX2 - count * meanX * meanX;
    if (denom == 0) return (double.nan, double.nan);
    final b = (sumXY - count * meanX * meanY) / denom;
    final a = meanY - b * meanX;
    return (a, b);
  }

  /// Linear regression `x = c + d y`.
  (double, double) get regressionXY {
    if (count < 2) return (double.nan, double.nan);
    final denom = sumY2 - count * meanY * meanY;
    if (denom == 0) return (double.nan, double.nan);
    final d = (sumXY - count * meanX * meanY) / denom;
    final c = meanX - d * meanY;
    return (c, d);
  }
}
