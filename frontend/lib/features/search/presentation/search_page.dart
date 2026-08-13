import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/cache/cache_ttl.dart';
import '../../../core/cache/paged_items.dart';
import '../../../core/di/providers.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/formatters/date_format.dart';
import '../../../core/formatters/money_format.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/prefetch/site_prefetch.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/field_action_icon.dart';
import '../../admin/data/admin_models.dart';
import '../../saves/data/site_ficha.dart';
import '../../saves/presentation/open_site_detail.dart';
import '../data/search_models.dart';
import '../data/search_repository.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key, required this.repository});

  final SearchRepository repository;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _queryCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _radiusCtrl = TextEditingController(text: '10');
  final _budgetMinCtrl = TextEditingController();
  final _budgetMaxCtrl = TextEditingController();

  bool _advanced = false;
  String? _categoryId;
  String? _transportGroup;
  bool _includePublic = true;
  bool _useMyLocation = false;
  bool _loading = false;
  List<SearchHit> _hits = const [];
  bool _searched = false;
  int _visibleCount = PagedItems.defaultPageSize;

  @override
  void dispose() {
    _queryCtrl.dispose();
    _locationCtrl.dispose();
    _radiusCtrl.dispose();
    _budgetMinCtrl.dispose();
    _budgetMaxCtrl.dispose();
    super.dispose();
  }

  Future<(double?, double?)> _maybeLocation() async {
    if (!_useMyLocation) return (null, null);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return (null, null);
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      return (pos.latitude, pos.longitude);
    } catch (_) {
      return (null, null);
    }
  }

  double? _parseNum(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t.replaceAll(',', '.'));
  }

  void _invalidateResults() {
    _hits = const [];
    _searched = false;
    _visibleCount = PagedItems.defaultPageSize;
  }

  Future<void> _runSearch() async {
    final text = _queryCtrl.text.trim();
    if (!_advanced && text.isEmpty) {
      AppToast.show(context, context.l10n.searchQueryRequired, error: true);
      setState(() {
        _hits = const [];
        _searched = true;
      });
      return;
    }

    setState(() {
      _loading = true;
      _searched = true;
      _hits = const [];
      _visibleCount = PagedItems.defaultPageSize;
    });

    try {
      final loc = await _maybeLocation();
      final locationExtra = _locationCtrl.text.trim();
      final filters = SearchFilters(
        query: text.isEmpty ? null : text,
        categoryId: _advanced ? _categoryId : null,
        locationQuery: _advanced && locationExtra.isNotEmpty
            ? locationExtra
            : null,
        lat: _advanced ? loc.$1 : null,
        lng: _advanced ? loc.$2 : null,
        radiusKm: _advanced && _useMyLocation
            ? _parseNum(_radiusCtrl.text)
            : null,
        transportGroup: _advanced ? _transportGroup : null,
        budgetMin: _advanced ? _parseNum(_budgetMinCtrl.text) : null,
        budgetMax: _advanced ? _parseNum(_budgetMaxCtrl.text) : null,
        includePublic: _includePublic,
      );
      final hits = await ref.read(swrLoaderProvider).load<List<SearchHit>>(
            key: CacheKeys.search(filters.cacheKey),
            ttl: CacheTtl.search,
            forceNetwork: true,
            decode: (payload) {
              final list = payload as List? ?? const [];
              return list
                  .whereType<Map>()
                  .map(
                    (e) => SearchHit.fromJson(Map<String, dynamic>.from(e)),
                  )
                  .toList();
            },
            encode: (value) => value.map((e) => e.toJson()).toList(),
            network: () => widget.repository.search(filters),
          );
      if (!mounted) return;
      setState(() {
        _hits = hits;
        _loading = false;
      });
      ref.read(sitePrefetchProvider).scheduleVisibleSites(
            hits.map((h) => h.siteId),
          );
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _loading = false);
      AppToast.error(context, e, stackTrace: st, logContext: 'search');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = ref.watch(
      categoriesProvider.select((a) => a.valueOrNull ?? const <Category>[]),
    );
    final roots = categories.where((c) => c.isRoot).toList();
    final children = categories.where((c) => !c.isRoot).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchTitle),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _advanced = !_advanced;
                _hits = const [];
                _searched = false;
              });
            },
            child: Text(_advanced ? l10n.searchSimple : l10n.searchAdvanced),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          Text(
            _advanced ? l10n.searchModeAdvanced : l10n.searchModeGeneral,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _queryCtrl,
            decoration: InputDecoration(
              labelText:
                  _advanced ? l10n.searchLabelText : l10n.actionSearch,
              hintText: l10n.searchHintPlace,
              border: const OutlineInputBorder(),
              suffixIcon: FieldActionIcon(
                icon: Icons.search,
                tooltip: l10n.actionSearch,
                loading: _loading,
                onPressed: _loading ? null : _runSearch,
              ),
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _runSearch(),
          ),
          if (_advanced) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _locationCtrl,
              decoration: InputDecoration(
                labelText: l10n.searchLabelLocationExtra,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.searchLabelCategory,
                border: const OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  value: _categoryId,
                  hint: Text(l10n.searchAny),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.searchAny),
                    ),
                    ...roots.map(
                      (r) => DropdownMenuItem<String?>(
                        value: r.id,
                        child: Text(r.nameEs),
                      ),
                    ),
                    ...children.map(
                      (c) => DropdownMenuItem<String?>(
                        value: c.id,
                        child: Text('  ${c.nameEs}'),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() {
                    _categoryId = v;
                    _invalidateResults();
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.searchLabelTransport,
                border: const OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  isExpanded: true,
                  value: _transportGroup,
                  hint: Text(l10n.searchAny),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.searchAny)),
                    DropdownMenuItem(
                      value: 'particular',
                      child: Text(l10n.searchTransportPrivate),
                    ),
                    DropdownMenuItem(
                      value: 'publico',
                      child: Text(l10n.searchTransportPublic),
                    ),
                    DropdownMenuItem(
                      value: 'otro',
                      child: Text(l10n.searchTransportOther),
                    ),
                  ],
                  onChanged: (v) => setState(() {
                    _transportGroup = v;
                    _invalidateResults();
                  }),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _budgetMinCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.searchBudgetMin,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _budgetMaxCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.searchBudgetMax,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.searchUseMyLocation),
              value: _useMyLocation,
              onChanged: (v) => setState(() {
                _useMyLocation = v;
                _invalidateResults();
              }),
            ),
            if (_useMyLocation)
              TextField(
                controller: _radiusCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.searchRadiusKm,
                  border: const OutlineInputBorder(),
                ),
              ),
            Text(
              l10n.searchHoursPlaceholder,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.searchIncludePublic),
            value: _includePublic,
            onChanged: (v) => setState(() {
              _includePublic = v;
              _invalidateResults();
            }),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _loading
                  ? null
                  : () {
                      _queryCtrl.clear();
                      _locationCtrl.clear();
                      _budgetMinCtrl.clear();
                      _budgetMaxCtrl.clear();
                      _radiusCtrl.text = '10';
                      setState(() {
                        _categoryId = null;
                        _transportGroup = null;
                        _useMyLocation = false;
                        _includePublic = true;
                        _hits = const [];
                        _searched = false;
                      });
                    },
              child: Text(l10n.actionClear),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          if (!_searched)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l10n.searchEmptyHint),
            )
          else if (_hits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l10n.searchNoResults),
            )
          else
            ...() {
              final visible = _hits.take(_visibleCount).toList();
              final hasMore = _visibleCount < _hits.length;
              return [
                ...visible.map(
                  (h) {
                    final accent =
                        h.isPublic ? AppColors.success : AppColors.purple;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: AppColors.surface,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: accent.withValues(alpha: 0.4),
                          ),
                        ),
                        child: InkWell(
                          onTap: () async {
                            final outcome = await openSiteDetail(
                              context,
                              hit: h,
                              siteId: h.siteId,
                            );
                            if (outcome != SiteDetailOutcome.none &&
                                mounted) {
                              await _runSearch();
                            }
                          },
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(width: 4, color: accent),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      12,
                                      8,
                                      12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          h.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: AppColors.foreground,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          [
                                            if (h.city != null &&
                                                h.city!.isNotEmpty)
                                              h.city!,
                                            if (h.department != null &&
                                                h.department!.isNotEmpty)
                                              h.department!,
                                            if (h.estimatedPriceAmount != null)
                                              formatMoney(
                                                h.estimatedPriceAmount!,
                                                currencyCode: h.currencyCode,
                                              ),
                                            if (h.distanceKm != null)
                                              '${h.distanceKm!.toStringAsFixed(1)} km',
                                          ].join(' · '),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                        if (h.isOwn ||
                                            h.isLinked ||
                                            h.isCatalog) ...[
                                          const SizedBox(height: 6),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: [
                                              if (h.isOwn)
                                                _SearchTag(
                                                  label: l10n.labelOwn,
                                                  color: AppColors.primary,
                                                ),
                                              if (h.isLinked)
                                                _SearchTag(
                                                  label: l10n.labelLinked,
                                                  color: AppColors.purple,
                                                ),
                                              if (h.isCatalog)
                                                _SearchTag(
                                                  label: l10n.labelCatalog,
                                                  color: AppColors.catServ,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (h.updatedAt != null)
                                        Text(
                                          formatDateDmY(h.updatedAt!),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.mutedDark,
                                          ),
                                        ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        '>',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (hasMore)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _visibleCount += PagedItems.defaultPageSize;
                      });
                    },
                    child: Text(
                      l10n.searchLoadMoreRemaining(
                        _hits.length - _visibleCount,
                      ),
                    ),
                  ),
              ];
            }(),
        ],
      ),
    );
  }
}

class _SearchTag extends StatelessWidget {
  const _SearchTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
