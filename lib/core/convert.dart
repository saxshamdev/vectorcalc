import 'dart:math' as math;

/// One unit in a conversion category.
///
/// Values are stored relative to the category's base unit:
/// `base = value * factor + offset`.
class UnitDef {
  final String id;
  final String name;
  final String symbol;
  final double factor;
  final double offset;

  const UnitDef(
    this.id,
    this.name,
    this.symbol,
    this.factor, {
    this.offset = 0,
  });

  double toBase(double value) => value * factor + offset;
  double fromBase(double base) => (base - offset) / factor;
}

class UnitCategory {
  final String id;
  final String name;
  final List<UnitDef> units;

  const UnitCategory(this.id, this.name, this.units);
}

const List<UnitCategory> unitCategories = [
  UnitCategory('length', 'Length', [
    UnitDef('m', 'Metre', 'm', 1),
    UnitDef('km', 'Kilometre', 'km', 1000),
    UnitDef('cm', 'Centimetre', 'cm', 0.01),
    UnitDef('mm', 'Millimetre', 'mm', 0.001),
    UnitDef('um', 'Micrometre', 'µm', 1e-6),
    UnitDef('nm', 'Nanometre', 'nm', 1e-9),
    UnitDef('ang', 'Ångström', 'Å', 1e-10),
    UnitDef('in', 'Inch', 'in', 0.0254),
    UnitDef('ft', 'Foot', 'ft', 0.3048),
    UnitDef('yd', 'Yard', 'yd', 0.9144),
    UnitDef('mi', 'Mile', 'mi', 1609.344),
    UnitDef('nmi', 'Nautical mile', 'nmi', 1852),
  ]),
  UnitCategory('mass', 'Mass', [
    UnitDef('kg', 'Kilogram', 'kg', 1),
    UnitDef('g', 'Gram', 'g', 0.001),
    UnitDef('mg', 'Milligram', 'mg', 1e-6),
    UnitDef('t', 'Tonne', 't', 1000),
    UnitDef('oz', 'Ounce', 'oz', 0.028349523125),
    UnitDef('lb', 'Pound', 'lb', 0.45359237),
    UnitDef('st', 'Stone', 'st', 6.35029318),
    UnitDef('ton', 'Short ton', 'ton', 907.18474),
  ]),
  UnitCategory('area', 'Area', [
    UnitDef('m2', 'Square metre', 'm²', 1),
    UnitDef('cm2', 'Square centimetre', 'cm²', 1e-4),
    UnitDef('mm2', 'Square millimetre', 'mm²', 1e-6),
    UnitDef('km2', 'Square kilometre', 'km²', 1e6),
    UnitDef('ha', 'Hectare', 'ha', 1e4),
    UnitDef('acre', 'Acre', 'acre', 4046.8564224),
    UnitDef('ft2', 'Square foot', 'ft²', 0.09290304),
    UnitDef('in2', 'Square inch', 'in²', 0.00064516),
    UnitDef('yd2', 'Square yard', 'yd²', 0.83612736),
  ]),
  UnitCategory('volume', 'Volume', [
    UnitDef('l', 'Litre', 'L', 1),
    UnitDef('ml', 'Millilitre', 'mL', 0.001),
    UnitDef('cm3', 'Cubic centimetre', 'cm³', 0.001),
    UnitDef('m3', 'Cubic metre', 'm³', 1000),
    UnitDef('gal', 'US gallon', 'gal', 3.785411784),
    UnitDef('galuk', 'UK gallon', 'gal UK', 4.54609),
    UnitDef('qt', 'US quart', 'qt', 0.946352946),
    UnitDef('pt', 'US pint', 'pt', 0.473176473),
    UnitDef('floz', 'US fluid ounce', 'fl oz', 0.0295735295625),
    UnitDef('cup', 'US cup', 'cup', 0.2365882365),
    UnitDef('tbsp', 'Tablespoon', 'tbsp', 0.01478676478125),
    UnitDef('tsp', 'Teaspoon', 'tsp', 0.00492892159375),
  ]),
  UnitCategory('speed', 'Speed', [
    UnitDef('mps', 'Metre/second', 'm/s', 1),
    UnitDef('kmh', 'Kilometre/hour', 'km/h', 1 / 3.6),
    UnitDef('mph', 'Mile/hour', 'mph', 0.44704),
    UnitDef('knot', 'Knot', 'kn', 0.5144444444444445),
    UnitDef('fps', 'Foot/second', 'ft/s', 0.3048),
    UnitDef('mach', 'Mach (sea level)', 'Ma', 340.29),
  ]),
  UnitCategory('temperature', 'Temperature', [
    UnitDef('c', 'Celsius', '°C', 1, offset: 273.15),
    UnitDef('f', 'Fahrenheit', '°F', 5 / 9, offset: 273.15 - 160 / 9),
    UnitDef('k', 'Kelvin', 'K', 1),
    UnitDef('r', 'Rankine', '°R', 5 / 9),
  ]),
  UnitCategory('energy', 'Energy', [
    UnitDef('j', 'Joule', 'J', 1),
    UnitDef('kj', 'Kilojoule', 'kJ', 1000),
    UnitDef('cal', 'Calorie', 'cal', 4.184),
    UnitDef('kcal', 'Kilocalorie', 'kcal', 4184),
    UnitDef('wh', 'Watt-hour', 'Wh', 3600),
    UnitDef('kwh', 'Kilowatt-hour', 'kWh', 3.6e6),
    UnitDef('ev', 'Electronvolt', 'eV', 1.602176634e-19),
    UnitDef('btu', 'British thermal unit', 'BTU', 1055.05585262),
    UnitDef('ftlb', 'Foot-pound', 'ft·lb', 1.3558179483314004),
  ]),
  UnitCategory('pressure', 'Pressure', [
    UnitDef('pa', 'Pascal', 'Pa', 1),
    UnitDef('kpa', 'Kilopascal', 'kPa', 1000),
    UnitDef('mpa', 'Megapascal', 'MPa', 1e6),
    UnitDef('bar', 'Bar', 'bar', 1e5),
    UnitDef('atm', 'Atmosphere', 'atm', 101325),
    UnitDef('mmhg', 'Millimetre of mercury', 'mmHg', 133.322387415),
    UnitDef('torr', 'Torr', 'Torr', 133.32236842105263),
    UnitDef('psi', 'Pound/square inch', 'psi', 6894.757293168),
  ]),
  UnitCategory('time', 'Time', [
    UnitDef('s', 'Second', 's', 1),
    UnitDef('ms', 'Millisecond', 'ms', 0.001),
    UnitDef('min', 'Minute', 'min', 60),
    UnitDef('h', 'Hour', 'h', 3600),
    UnitDef('day', 'Day', 'day', 86400),
    UnitDef('week', 'Week', 'week', 604800),
    UnitDef('month', 'Month (average)', 'month', 2629800),
    UnitDef('year', 'Year (Julian)', 'year', 31557600),
  ]),
  UnitCategory('angle', 'Angle', [
    UnitDef('rad', 'Radian', 'rad', 1),
    UnitDef('deg', 'Degree', '°', math.pi / 180),
    UnitDef('grad', 'Gradian', 'grad', math.pi / 200),
    UnitDef('turn', 'Turn', 'turn', 2 * math.pi),
    UnitDef('arcmin', 'Arcminute', '′', math.pi / 10800),
    UnitDef('arcsec', 'Arcsecond', '″', math.pi / 648000),
  ]),
  UnitCategory('data', 'Data', [
    UnitDef('b', 'Byte', 'B', 1),
    UnitDef('bit', 'Bit', 'bit', 0.125),
    UnitDef('kb', 'Kilobyte', 'kB', 1000),
    UnitDef('mb', 'Megabyte', 'MB', 1e6),
    UnitDef('gb', 'Gigabyte', 'GB', 1e9),
    UnitDef('tb', 'Terabyte', 'TB', 1e12),
    UnitDef('kib', 'Kibibyte', 'KiB', 1024),
    UnitDef('mib', 'Mebibyte', 'MiB', 1048576),
    UnitDef('gib', 'Gibibyte', 'GiB', 1073741824),
  ]),
];

UnitCategory? categoryById(String id) {
  for (final c in unitCategories) {
    if (c.id == id) return c;
  }
  return null;
}

UnitDef? unitById(UnitCategory category, String id) {
  for (final u in category.units) {
    if (u.id == id) return u;
  }
  return null;
}

/// Converts [value] from one unit to another.
double convertUnit(double value, UnitDef from, UnitDef to) {
  if (to.factor == 0) return double.nan;
  return to.fromBase(from.toBase(value));
}
