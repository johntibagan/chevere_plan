import 'package:flutter/material.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/testing/widget_keys.dart';
import '../data/plan_models.dart';

/// Línea de tiempo minimalista de paradas del plan.
class PlanTimeline extends StatelessWidget {
  const PlanTimeline({
    super.key,
    required this.stops,
    required this.onStopTap,
    this.onToggleVisited,
    this.onRemove,
    this.onReorder,
    this.emptyLabel,
    this.bottomPadding = AppSpacing.xxl,
  });

  final List<PlanStop> stops;
  final void Function(PlanStop stop) onStopTap;
  final void Function(PlanStop stop)? onToggleVisited;
  final void Function(PlanStop stop)? onRemove;
  /// Si hay 2+ paradas, muestra asa para arrastrar y persistir el orden.
  final void Function(int oldIndex, int newIndex)? onReorder;
  final String? emptyLabel;
  final double bottomPadding;

  bool get _canReorder => onReorder != null && stops.length > 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (stops.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          emptyLabel ?? l10n.planTimelineEmpty,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
              ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final listPadding = EdgeInsets.fromLTRB(
      AppSpacing.lg,
      _canReorder ? AppSpacing.xs : AppSpacing.md,
      AppSpacing.lg,
      bottomPadding,
    );

    Widget item(BuildContext context, int index) {
      final stop = stops[index];
      return _StopTile(
        key: ValueKey(stop.id),
        stop: stop,
        isLast: index == stops.length - 1,
        dragIndex: _canReorder ? index : null,
        onTap: () => onStopTap(stop),
        onToggleVisited:
            onToggleVisited == null ? null : () => onToggleVisited!(stop),
        onRemove: onRemove == null ? null : () => onRemove!(stop),
      );
    }

    if (!_canReorder) {
      return ListView.builder(
        padding: listPadding,
        itemCount: stops.length,
        itemBuilder: item,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            l10n.planReorderHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: listPadding,
            buildDefaultDragHandles: false,
            itemCount: stops.length,
            onReorderItem: onReorder!,
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  final t = Curves.easeInOut.transform(animation.value);
                  return Material(
                    elevation: 2 + 4 * t,
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    child: child,
                  );
                },
                child: child,
              );
            },
            itemBuilder: item,
          ),
        ),
      ],
    );
  }
}

class _StopTile extends StatelessWidget {
  const _StopTile({
    super.key,
    required this.stop,
    required this.isLast,
    required this.onTap,
    this.dragIndex,
    this.onToggleVisited,
    this.onRemove,
  });

  final PlanStop stop;
  final bool isLast;
  final int? dragIndex;
  final VoidCallback onTap;
  final VoidCallback? onToggleVisited;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: stop.isVisited
                          ? AppColors.success
                          : AppColors.primary,
                      border: Border.all(
                        color: AppColors.foreground.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: AppColors.border,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: isLast ? 0 : AppSpacing.lg,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stop.siteName,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  decoration: stop.isVisited
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                          if (stop.city != null && stop.city!.isNotEmpty)
                            Text(
                              stop.city!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.muted),
                            ),
                        ],
                      ),
                    ),
                    if (onToggleVisited != null)
                      IconButton(
                        tooltip: stop.isVisited
                            ? l10n.planMarkPending
                            : l10n.planMarkDone,
                        visualDensity: VisualDensity.compact,
                        onPressed: onToggleVisited,
                        icon: Icon(
                          stop.isVisited
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                          color: stop.isVisited
                              ? AppColors.success
                              : AppColors.muted,
                          size: 22,
                        ),
                      ),
                    if (onRemove != null)
                      IconButton(
                        tooltip: l10n.planRemoveStop,
                        visualDensity: VisualDensity.compact,
                        onPressed: onRemove,
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 22,
                          color: AppColors.muted,
                        ),
                      ),
                    if (dragIndex != null)
                      ReorderableDragStartListener(
                        index: dragIndex!,
                        child: Padding(
                          key: WidgetKeys.planReorderHandle,
                          padding: const EdgeInsets.only(top: 8),
                          child: Tooltip(
                            message: l10n.planReorderStop,
                            child: Icon(
                              Icons.drag_handle,
                              color: AppColors.muted,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
