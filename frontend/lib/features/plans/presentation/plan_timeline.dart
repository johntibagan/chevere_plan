import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../data/plan_models.dart';

/// Línea de tiempo minimalista de paradas del plan.
class PlanTimeline extends StatelessWidget {
  const PlanTimeline({
    super.key,
    required this.stops,
    required this.onStopTap,
    this.onRemove,
    this.emptyLabel,
  });

  final List<PlanStop> stops;
  final void Function(PlanStop stop) onStopTap;
  final void Function(PlanStop stop)? onRemove;
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (stops.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          emptyLabel ?? 'Sin sitios aún',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
              ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
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
                        if (onRemove != null)
                          IconButton(
                            tooltip: 'Quitar',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => onRemove!(stop),
                            icon: const Icon(Icons.close, size: 18),
                          )
                        else
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.mutedDark,
                            size: 20,
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
