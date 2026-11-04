const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// e.g. `01 November 2025`
String formatLongDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]} ${d.year}';

/// e.g. `5400` -> `5,400`
String formatThousands(num n) {
  final s = n.round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// e.g. `24.5` -> `$24.50`
String formatPrice(double v) => '\$${v.toStringAsFixed(2)}';
