import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'field_action_icon.dart';

/// Campo de búsqueda: lupa dentro del input (acción), no un botón suelto.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.searchTooltip,
    required this.onSearch,
    this.loading = false,
  });

  final TextEditingController controller;
  final String hint;
  final String searchTooltip;
  final VoidCallback onSearch;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSearch(),
      style: const TextStyle(fontSize: 13, color: AppColors.foreground),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.mutedDark),
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        prefixIcon: FieldActionIcon(
          icon: Icons.search_rounded,
          tooltip: searchTooltip,
          loading: loading,
          onPressed: loading ? null : onSearch,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
