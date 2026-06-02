import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class ClickHint extends StatelessWidget {
  const ClickHint({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.touch_app_outlined, size: 14, color: AppColors.gray),
        SizedBox(width: 4),
        Text('Clique para ver detalhes',
            style: TextStyle(fontSize: 11, color: AppColors.gray)),
      ],
    );
  }
}

class SearchRow extends StatelessWidget {
  const SearchRow({super.key, required this.hint});
  final String hint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final children = [
          TextField(
            decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search), hintText: hint),
          ),
          SizedBox(width: compact ? 0 : 8, height: compact ? 8 : 0),
          TextField(
            readOnly: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.tune),
              hintText: 'Todos',
              suffixIcon: const Icon(Icons.expand_more),
            ),
          ),
        ];
        if (compact) {
          return Column(children: children);
        }
        return Row(
          children: [
            Expanded(child: children[0]),
            children[1],
            SizedBox(width: 170, child: children[2]),
          ],
        );
      },
    );
  }
}
