import 'package:flutter/material.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/testing/widget_keys.dart';
import '../../saves/presentation/site_look_cover.dart';
import '../data/plan_models.dart';

/// Letra de waypoint estilo Google Maps: 0→A, 1→B, … 25→Z, 26→AA.
String planWaypointLetter(int index) {
  var i = index;
  final chars = <String>[];
  while (i >= 0) {
    chars.add(String.fromCharCode(65 + (i % 26)));
    i = (i ~/ 26) - 1;
  }
  return chars.reversed.join();
}

/// Índice entre paradas **pendientes** (visitadas no cuentan en A, B, C…).
int planPendingWaypointIndex(List<PlanStop> stops, int stopIndex) {
  var n = 0;
  for (var i = 0; i < stopIndex; i++) {
    if (!stops[i].isVisited) n++;
  }
  return n;
}

/// Línea de tiempo: **Mi ubicación** (punto) + pendientes **A, B, C…**; visitadas = punto.
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
  final void Function(int oldIndex, int newIndex)? onReorder;
  final String? emptyLabel;
  final double bottomPadding;

  bool get _canReorder => onReorder != null && stops.length > 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final listPadding = EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.sm,
      AppSpacing.lg,
      bottomPadding,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_canReorder)
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
        Padding(
          padding: EdgeInsets.fromLTRB(
            listPadding.left,
            listPadding.top,
            listPadding.right,
            0,
          ),
          child: _OriginTile(
            label: l10n.planMyLocation,
            isLast: stops.isEmpty,
          ),
        ),
        Expanded(
          child: stops.isEmpty
              ? Padding(
                  padding: EdgeInsets.fromLTRB(
                    listPadding.left,
                    AppSpacing.md,
                    listPadding.right,
                    listPadding.bottom,
                  ),
                  child: Text(
                    emptyLabel ?? l10n.planTimelineEmpty,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                        ),
                    textAlign: TextAlign.center,
                  ),
                )
              : _canReorder
                  ? ReorderableListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        listPadding.left,
                        0,
                        listPadding.right,
                        listPadding.bottom,
                      ),
                      buildDefaultDragHandles: false,
                      itemCount: stops.length,
                      onReorderItem: onReorder!,
                      proxyDecorator: (child, index, animation) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            final t =
                                Curves.easeInOut.transform(animation.value);
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
                      itemBuilder: (context, index) => _stopTile(context, index),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        listPadding.left,
                        0,
                        listPadding.right,
                        listPadding.bottom,
                      ),
                      itemCount: stops.length,
                      itemBuilder: (context, index) => _stopTile(context, index),
                    ),
        ),
      ],
    );
  }

  Widget _stopTile(BuildContext context, int index) {
    final stop = stops[index];
    final letter = stop.isVisited
        ? null
        : planWaypointLetter(planPendingWaypointIndex(stops, index));
    return _StopTile(
      key: ValueKey(stop.id),
      stop: stop,
      letter: letter,
      isLast: index == stops.length - 1,
      dragIndex: _canReorder ? index : null,
      onTap: () => onStopTap(stop),
      onToggleVisited:
          onToggleVisited == null ? null : () => onToggleVisited!(stop),
      onRemove: onRemove == null ? null : () => onRemove!(stop),
    );
  }
}

class _WaypointDot extends StatelessWidget {
  const _WaypointDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _WaypointBadge extends StatelessWidget {
  const _WaypointBadge({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        border: Border.all(
          color: AppColors.foreground.withValues(alpha: 0.15),
        ),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: letter.length > 1 ? 9 : 11,
          fontWeight: FontWeight.w800,
          color: AppColors.onImage,
          height: 1,
        ),
      ),
    );
  }
}

class _OriginTile extends StatelessWidget {
  const _OriginTile({
    required this.label,
    required this.isLast,
  });

  final String label;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                const _WaypointDot(),
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
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? AppSpacing.sm : AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(
                      Icons.my_location,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: AppColors.mutedDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StopTile extends StatelessWidget {
  const _StopTile({
    super.key,
    required this.stop,
    required this.letter,
    required this.isLast,
    required this.onTap,
    this.dragIndex,
    this.onToggleVisited,
    this.onRemove,
  });

  final PlanStop stop;
  final String? letter;
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
                  if (letter != null)
                    _WaypointBadge(letter: letter!)
                  else
                    const _WaypointDot(),
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
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: isLast ? 0 : AppSpacing.lg,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: SiteLookCover(
                          siteId: stop.siteId,
                          categoryNames: stop.categoryNames,
                          coverStoragePath: stop.coverStoragePath,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
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
                        icon: Icon(
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
