import 'package:flutter/material.dart';

import '../domain/geo_fuzzy.dart';

/// Campo de texto + coincidencias locales. Hay que elegir una opción (id real).
class GeoTypeaheadField<T extends Object> extends StatefulWidget {
  const GeoTypeaheadField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.items,
    required this.labelOf,
    required this.onSelected,
    this.selected,
    this.enabled = true,
    this.label = '',
    this.helper,
    this.decoration,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T?> onSelected;
  final T? selected;
  final bool enabled;
  final String label;
  final String? helper;
  final InputDecoration? decoration;

  @override
  State<GeoTypeaheadField<T>> createState() => _GeoTypeaheadFieldState<T>();
}

class _GeoTypeaheadFieldState<T extends Object>
    extends State<GeoTypeaheadField<T>> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(covariant GeoTypeaheadField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocus);
      widget.focusNode.addListener(_onFocus);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocus);
    super.dispose();
  }

  void _onFocus() {
    if (widget.focusNode.hasFocus) return;
    _commitOrRevert();
  }

  void _commitOrRevert() {
    final text = widget.controller.text.trim();
    if (text.isEmpty) {
      if (widget.selected != null) widget.onSelected(null);
      return;
    }
    final selected = widget.selected;
    if (selected != null && widget.labelOf(selected) == text) {
      return;
    }
    final hits = GeoFuzzy.filter(widget.items, text, widget.labelOf, limit: 5);
    if (hits.length == 1 ||
        (hits.isNotEmpty &&
            GeoFuzzy.fold(widget.labelOf(hits.first)) == GeoFuzzy.fold(text))) {
      widget.controller.text = widget.labelOf(hits.first);
      widget.onSelected(hits.first);
      return;
    }
    if (selected != null) {
      widget.controller.text = widget.labelOf(selected);
    } else {
      widget.controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<T>(
      textEditingController: widget.controller,
      focusNode: widget.focusNode,
      displayStringForOption: widget.labelOf,
      optionsBuilder: (value) {
        if (!widget.enabled) return const Iterable.empty();
        return GeoFuzzy.filter(widget.items, value.text, widget.labelOf);
      },
      onSelected: (item) {
        widget.controller.text = widget.labelOf(item);
        widget.onSelected(item);
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: widget.enabled,
          textCapitalization: TextCapitalization.words,
          decoration: (widget.decoration ??
                  InputDecoration(
                    labelText: widget.label,
                    border: const OutlineInputBorder(),
                    helperText: widget.helper,
                  ))
              .copyWith(
            suffixIcon: widget.selected != null
                ? IconButton(
                    tooltip: 'Quitar',
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: widget.enabled
                        ? () {
                            controller.clear();
                            widget.onSelected(null);
                          }
                        : null,
                  )
                : const Icon(Icons.arrow_drop_down),
          ),
          onChanged: (v) {
            final sel = widget.selected;
            if (sel != null && v.trim() != widget.labelOf(sel)) {
              widget.onSelected(null);
            }
          },
          onSubmitted: (_) {
            _commitOrRevert();
            onSubmitted();
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final opts = options.toList();
        if (opts.isEmpty) {
          return const SizedBox.shrink();
        }
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 6,
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220, minWidth: 280),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: opts.length,
                itemBuilder: (context, i) {
                  final item = opts[i];
                  return ListTile(
                    dense: true,
                    title: Text(widget.labelOf(item)),
                    onTap: () => onSelected(item),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
