import 'dart:math' as math;

/// A double-precision complex number used by CMPLX and the equation solvers.
class Complex {
  final double re;
  final double im;

  const Complex(this.re, [this.im = 0]);

  static const Complex zero = Complex(0);
  static const Complex one = Complex(1);
  static const Complex i = Complex(0, 1);

  bool get isReal => im == 0;
  double get magnitude => math.sqrt(re * re + im * im);
  double get argument => math.atan2(im, re);
  Complex get conjugate => Complex(re, -im);

  Complex operator +(Complex o) => Complex(re + o.re, im + o.im);
  Complex operator -(Complex o) => Complex(re - o.re, im - o.im);
  Complex operator -() => Complex(-re, -im);

  Complex operator *(Complex o) =>
      Complex(re * o.re - im * o.im, re * o.im + im * o.re);

  Complex operator /(Complex o) {
    final d = o.re * o.re + o.im * o.im;
    if (d == 0) return const Complex(double.nan, double.nan);
    return Complex(
      (re * o.re + im * o.im) / d,
      (im * o.re - re * o.im) / d,
    );
  }

  Complex scale(double k) => Complex(re * k, im * k);

  Complex powInt(int n) {
    var result = Complex.one;
    var base = this;
    var e = n.abs();
    while (e > 0) {
      if (e & 1 == 1) result = result * base;
      base = base * base;
      e >>= 1;
    }
    return n < 0 ? Complex.one / result : result;
  }

  Complex sqrt() {
    final r = magnitude;
    if (r == 0) return Complex.zero;
    final a = math.sqrt((r + re) / 2);
    final b = math.sqrt((r - re) / 2);
    return Complex(a, im < 0 ? -b : b);
  }

  @override
  String toString() => isReal ? '$re' : '$re${im < 0 ? '-' : '+'}${im.abs()}i';
}
