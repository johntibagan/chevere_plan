import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'field_action_icon.dart';

/// Campo de búsqueda: lupa (buscar) + **X** (borrar texto) dentro del input.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.searchTooltip,
    required this.onSearch,
    this.clearTooltip,
    this.loading = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final String searchTooltip;
  final VoidCallback onSearch;
  /// Tooltip de la X. Si es null, igual se muestra la X con tooltip vacío.
  final String? clearTooltip;
  final bool loading;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.isNotEmpty;
        return TextField(
          controller: controller,
          textInputAction: TextInputAction.search,
          onChanged: onChanged,
          onSubmitted: (_) => onSearch(),
          style: TextStyle(fontSize: 13, color: AppColors.foreground),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: AppColors.mutedDark),
            filled: true,
            fillColor: AppColors.surface,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            prefixIcon: FieldActionIcon(
              icon: Icons.search_rounded,
              tooltip: searchTooltip,
              loading: loading,
              onPressed: loading ? null : onSearch,
            ),
            // Siempre reserva el hueco de la X cuando hay texto (no depende de loading).
            suffixIcon: hasText
                ? IconButton(
                    tooltip: clearTooltip,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    icon: Icon(
                      Icons.cancel_rounded,
                      size: 20,
                      color: AppColors.muted,
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged?.call('');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        );
      },
    );
  }
}
