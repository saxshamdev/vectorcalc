import 'functions.dart';

/// Converts an angle between the three calculator units.
double convertAngle(double value, AngleMode from, AngleMode to) =>
    fromRadians(toRadians(value, from), to);
