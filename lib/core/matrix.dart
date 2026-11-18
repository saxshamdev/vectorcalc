/// A small dense matrix with the operations used by MATRIX mode.
class Matrix {
  final int rows;
  final int cols;
  final List<List<double>> data;

  Matrix(this.rows, this.cols, List<List<double>> values)
      : assert(values.length == rows, 'row count mismatch'),
        assert(values.every((r) => r.length == cols), 'column count mismatch'),
        data = [for (final r in values) [...r]];

  factory Matrix.filled(int rows, int cols, [double value = 0]) =>
      Matrix(rows, cols, [
        for (var r = 0; r < rows; r++) List<double>.filled(cols, value),
      ]);

  factory Matrix.identity(int n) {
    final m = Matrix.filled(n, n);
    for (var i = 0; i < n; i++) {
      m.data[i][i] = 1;
    }
    return m;
  }

  double at(int r, int c) => data[r][c];
  void set(int r, int c, double v) => data[r][c] = v;

  bool get isSquare => rows == cols;

  Matrix operator +(Matrix o) {
    _requireSameShape(o);
    return Matrix(rows, cols, [
      for (var r = 0; r < rows; r++)
        [for (var c = 0; c < cols; c++) data[r][c] + o.data[r][c]],
    ]);
  }

  Matrix operator -(Matrix o) {
    _requireSameShape(o);
    return Matrix(rows, cols, [
      for (var r = 0; r < rows; r++)
        [for (var c = 0; c < cols; c++) data[r][c] - o.data[r][c]],
    ]);
  }

  Matrix scale(double k) => Matrix(rows, cols, [
        for (var r = 0; r < rows; r++)
          [for (var c = 0; c < cols; c++) data[r][c] * k],
      ]);

  Matrix operator *(Matrix o) {
    if (cols != o.rows) {
      throw ArgumentError('Dimension mismatch for multiplication');
    }
    final out = Matrix.filled(rows, o.cols);
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < o.cols; c++) {
        var sum = 0.0;
        for (var k = 0; k < cols; k++) {
          sum += data[r][k] * o.data[k][c];
        }
        out.data[r][c] = sum;
      }
    }
    return out;
  }

  Matrix transpose() => Matrix(cols, rows, [
        for (var c = 0; c < cols; c++)
          [for (var r = 0; r < rows; r++) data[r][c]],
      ]);

  double determinant() {
    if (!isSquare) throw ArgumentError('Determinant needs a square matrix');
    final a = [
      for (var r = 0; r < rows; r++) [...data[r]],
    ];
    var det = 1.0;
    for (var col = 0; col < rows; col++) {
      var pivot = col;
      for (var r = col + 1; r < rows; r++) {
        if (a[r][col].abs() > a[pivot][col].abs()) pivot = r;
      }
      if (a[pivot][col].abs() < 1e-12) return 0;
      if (pivot != col) {
        final tmp = a[pivot];
        a[pivot] = a[col];
        a[col] = tmp;
        det = -det;
      }
      det *= a[col][col];
      for (var r = col + 1; r < rows; r++) {
        final f = a[r][col] / a[col][col];
        for (var c = col; c < rows; c++) {
          a[r][c] -= f * a[col][c];
        }
      }
    }
    return det;
  }

  /// Returns the inverse, or null when the matrix is singular.
  Matrix? inverse() {
    if (!isSquare) return null;
    final n = rows;
    final aug = [
      for (var r = 0; r < n; r++)
        [...data[r], ...List<double>.generate(n, (c) => r == c ? 1.0 : 0.0)],
    ];
    for (var col = 0; col < n; col++) {
      var pivot = col;
      for (var r = col + 1; r < n; r++) {
        if (aug[r][col].abs() > aug[pivot][col].abs()) pivot = r;
      }
      if (aug[pivot][col].abs() < 1e-12) return null;
      if (pivot != col) {
        final tmp = aug[pivot];
        aug[pivot] = aug[col];
        aug[col] = tmp;
      }
      final pv = aug[col][col];
      for (var c = 0; c < 2 * n; c++) {
        aug[col][c] /= pv;
      }
      for (var r = 0; r < n; r++) {
        if (r == col) continue;
        final f = aug[r][col];
        if (f == 0) continue;
        for (var c = 0; c < 2 * n; c++) {
          aug[r][c] -= f * aug[col][c];
        }
      }
    }
    return Matrix(n, n, [
      for (var r = 0; r < n; r++) [for (var c = 0; c < n; c++) aug[r][n + c]],
    ]);
  }

  void _requireSameShape(Matrix o) {
    if (rows != o.rows || cols != o.cols) {
      throw ArgumentError('Matrix dimensions must match');
    }
  }

  @override
  String toString() => data
      .map((r) => r.map((v) => v.toStringAsFixed(4)).join('  '))
      .join('\n');
}
