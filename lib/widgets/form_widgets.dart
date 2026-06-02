import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField(
      {super.key,
      required this.label,
      required this.hint,
      this.maxLines = 1,
      this.enabled = true,
      this.controller});
  final String label;
  final String hint;
  final int maxLines;
  final bool enabled;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4)),
          const SizedBox(height: 5),
          TextField(
              controller: controller,
              enabled: enabled,
              maxLines: maxLines,
              decoration: InputDecoration(hintText: hint)),
        ],
      ),
    );
  }
}

class AppDropdownField extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4)),
          const SizedBox(height: 5),
          DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            decoration: const InputDecoration(),
            items: [
              for (final option in options)
                DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ),
            ],
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class AppMultiSelectField extends StatelessWidget {
  const AppMultiSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.allOption,
    required this.onChanged,
  });

  final String label;
  final List<String> options;
  final List<String> selected;
  final String allOption;
  final ValueChanged<List<String>> onChanged;

  List<String> toggledValues(List<String> current, String option) {
    if (option == allOption) {
      return [allOption];
    }

    final next = current.toSet()..remove(allOption);
    if (next.contains(option)) {
      next.remove(option);
    } else {
      next.add(option);
    }

    return next.isEmpty ? [allOption] : next.toList();
  }

  Future<void> openPicker(BuildContext context) async {
    var draft = List<String>.from(selected);
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(label),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final option in options)
                      CheckboxListTile(
                        value: draft.contains(option),
                        onChanged: (_) {
                          setDialogState(
                              () => draft = toggledValues(draft, option));
                        },
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(option),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(draft),
                icon: const Icon(Icons.check),
                label: const Text('Aplicar'),
              ),
            ],
          );
        },
      ),
    );

    if (result != null) {
      onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = selected.join(', ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4)),
          const SizedBox(height: 5),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => openPicker(context),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayText,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.grayDark),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded,
                      color: AppColors.gray),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppFormGrid extends StatelessWidget {
  const AppFormGrid({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(children: children);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i != children.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}
