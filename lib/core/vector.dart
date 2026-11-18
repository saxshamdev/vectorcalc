import 'dart:math' as math;

/// A 3D vector; 2D vectors simply leave z at zero.
class Vec3 {
  final double x;
  final double y;
  final double z;

  const Vec3(this.x, this.y, [this.z = 0]);

  double get magnitude => math.sqrt(x * x + y * y + z * z);

  Vec3 get unit {
    final m = magnitude;
    return m == 0 ? const Vec3(0, 0, 0) : Vec3(x / m, y / m, z / m);
  }

  Vec3 operator +(Vec3 o) => Vec3(x + o.x, y + o.y, z + o.z);
  Vec3 operator -(Vec3 o) => Vec3(x - o.x, y - o.y, z - o.z);
  Vec3 scale(double k) => Vec3(x * k, y * k, z * k);

  double dot(Vec3 o) => x * o.x + y * o.y + z * o.z;

  Vec3 cross(Vec3 o) => Vec3(
        y * o.z - z * o.y,
        z * o.x - x * o.z,
        x * o.y - y * o.x,
      );

  /// Angle between two vectors in degrees.
  double angleDeg(Vec3 o) {
    final denom = magnitude * o.magnitude;
    if (denom == 0) return double.nan;
    final cos = (dot(o) / denom).clamp(-1.0, 1.0);
    return math.acos(cos) * 180 / math.pi;
  }

  List<double> get components => [x, y, z];

  @override
  String toString() => '($x, $y, $z)';
}
