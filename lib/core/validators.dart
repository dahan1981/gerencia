class FormValidators {
  static bool hasText(String value) => value.trim().isNotEmpty;

  static bool isEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
  }

  static bool isBrazilianDate(String value) {
    final parts = value.trim().split('/');
    if (parts.length != 3) return false;
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return false;
    if (year < 1900 || month < 1 || month > 12) return false;
    final lastDay = DateTime(year, month + 1, 0).day;
    return day >= 1 && day <= lastDay;
  }

  static bool isTime(String value) {
    final match = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').firstMatch(value.trim());
    return match != null;
  }

  static bool isPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 10 && digits.length <= 11;
  }

  static bool isCpfLike(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length == 11;
  }
}
