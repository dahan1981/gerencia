import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

Color statusColor(String status) {
  final value = status.toLowerCase();
  if (value.contains('aceito') ||
      value.contains('assinado') ||
      value.contains('recebido') ||
      value.contains('ativo') ||
      value.contains('vigente')) {
    return AppColors.green;
  }
  if (value.contains('pendente') ||
      value.contains('planejado') ||
      value.contains('revisao')) {
    return AppColors.warning;
  }
  if (value.contains('negado')) {
    return const Color(0xFFA32D2D);
  }
  return AppColors.rose;
}
