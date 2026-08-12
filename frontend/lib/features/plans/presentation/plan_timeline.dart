import 'package:flutter/material.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../data/plan_models.dart';

/// Línea de tiempo minimalista de paradas del plan.
class PlanTimeline extends StatelessWidget {
  const PlanTimeline({
    super.key,
    required this.stops,
    required this.onStopTap,
    this.onToggleVisited,
    this.onRemove,
    this.emptyLabel,
    this.bottomPadding = AppSpacing.xxl,
  });

  final List<PlanStop> stops;
  final void Function(PlanStop stop) onStopTap;
  final void Function(PlanStop stop)? onToggleVisited;
  final void Function(PlanStop stop)? onRemove;
  final String? emptyLabel;
  final double bottomPadding;

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

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        bottomPadding,
      ),
      itemCount: stops.length,
      itemBuilder: (context, index) {
        final stop = stops[index];
        final isLast = index == stops.length - 1;
        return InkWell(
          onTap: () => onStopTap(stop),
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
                            onPressed: () => onToggleVisited!(stop),
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
                            onPressed: () => onRemove!(stop),
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 22,
                              color: AppColors.muted,
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
      },
    );
  }
}
