import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class DocumentNumber extends StatelessWidget {
  const DocumentNumber({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Numero automatico',
            style: TextStyle(
                fontSize: 12,
                color: AppColors.gray,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.roseLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.rose),
          ),
          child: Text(text,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.roseDark,
                  fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
