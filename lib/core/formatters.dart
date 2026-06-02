String twoDigits(int value) => value.toString().padLeft(2, '0');

String appDate(DateTime date) =>
    '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';

DateTime todayDate() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

String currentTime() {
  final now = DateTime.now();
  return '${twoDigits(now.hour)}:${twoDigits(now.minute)}';
}

const monthNames = [
  'Janeiro',
  'Fevereiro',
  'Marco',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];
