import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/config/env.dart';
import '../../../core/di/providers.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/testing/widget_keys.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_rebuild.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/field_action_icon.dart';
import '../../home/data/device_location.dart';
import '../data/geo_place.dart';
import '../data/google_places_client.dart';
import '../data/place_geocoder.dart';

/// Mapa Google + búsqueda solo al pulsar 🔍 (anti-fugas). Devuelve [GeoPlace].
class LocationPickerPage extends ConsumerStatefulWidget {
  const LocationPickerPage({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  final double? initialLat;
  final double? initialLng;

  @override
  ConsumerState<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends ConsumerState<LocationPickerPage> {
  static const _colombiaCenter = LatLng(4.5709, -74.2973);

  PlaceGeocoder get _geocoder => ref.read(placeGeocoderProvider);
  GooglePlacesClient get _places => ref.read(googlePlacesClientProvider);

  final _searchCtrl = TextEditingController();
  GoogleMapController? _mapController;

  late LatLng _pin;
  GeoPlace? _place;
  List<PlacePrediction> _predictions = const [];
  List<GeoPlace> _nearbyPlaces = const [];
  GeoPlace? _pinOnlyPlace;
  String? _sessionToken;
  bool _locating = false;
  bool _busy = false;
  String? _hint;
  DateTime? _lastTapAt;
  late bool _hasUserSelection;
  int _tapGen = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _pin = LatLng(widget.initialLat!, widget.initialLng!);
      _hasUserSelection = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _onMapPoint(_pin));
    } else {
      _pin = _colombiaCenter;
      _hasUserSelection = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hint == null && !Env.hasGoogleMapsKey && !Env.hasGeoapifyKey) {
      _hint = context.l10n.locationMapsUnavailable;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  bool get _canConfirm => _hasUserSelection && !_busy;

  Future<void> _onMapPoint(LatLng point) async {
    final gen = ++_tapGen;
    setState(() {
      _busy = true;
      _hasUserSelection = true;
      _predictions = const [];
      _nearbyPlaces = const [];
      _hint = null;
    });

    GeoPlace? reverse;
    List<GeoPlace> nearby = const [];
    try {
      final reverseFuture = _geocoder.reverse(
        lat: point.latitude,
        lng: point.longitude,
      );
      final nearbyFuture = _places.isConfigured
          ? _places.searchNearby(lat: point.latitude, lng: point.longitude)
          : Future.value(const <GeoPlace>[]);
      reverse = await reverseFuture;
      nearby = await nearbyFuture;
    } catch (e) {
      if (!mounted || gen != _tapGen) return;
      AppToast.error(context, e, logContext: 'location_map_point');
    }

    if (!mounted || gen != _tapGen) return;

    final pinPlace = (reverse ??
            GeoPlace(lat: point.latitude, lng: point.longitude))
        .copyWith(
      lat: point.latitude,
      lng: point.longitude,
      isPlaceFicha: false,
    );

    setState(() {
      _pin = point;
      _pinOnlyPlace = pinPlace;
      _nearbyPlaces = nearby;
      // Por defecto el pin tocado; el usuario elige ficha en los chips.
      _place = pinPlace;
      _busy = false;
      if (nearby.isNotEmpty) {
        _hint = null;
      }
    });
  }

  /// Solo botón / tecla Enter — no onChanged (cero llamadas por tecla).
  Future<void> _runSearch(String value) async {
    final q = value.trim();
    if (q.length < 3) {
      if (mounted) {
        setState(() {
          _predictions = const [];
          _hint = context.l10n.locationSearchMinChars;
        });
      }
      return;
    }
    setState(() {
      _busy = true;
      _hint = null;
      _predictions = const [];
      _sessionToken = _places.isConfigured ? _places.newSessionToken() : null;
    });
    try {
      if (_places.isConfigured) {
        final hits = await _places.autocomplete(
          input: q,
          sessionToken: _sessionToken!,
          biasLat: _pin.latitude,
          biasLng: _pin.longitude,
        );
        if (!mounted) return;
        setState(() {
          _predictions = hits;
          _busy = false;
          if (hits.isEmpty) _hint = context.l10n.locationNoMatches;
        });
        return;
      }

      // Fallback Geoapify/Nominatim (sin sesión Google).
      final hits = await _geocoder.search(
        q,
        biasLat: _pin.latitude,
        biasLng: _pin.longitude,
      );
      if (!mounted) return;
      setState(() {
        _predictions = hits
            .map(
              (h) => PlacePrediction(
                placeId: h.placeId ?? '${h.lat},${h.lng}',
                primaryText: h.name ?? h.displayName ?? 'Lugar',
                secondaryText: h.displayName,
              ),
            )
            .toList();
        _busy = false;
        if (hits.isEmpty) _hint = context.l10n.locationNoMatches;
        _fallbackById = {
          for (final h in hits)
            (h.placeId ?? '${h.lat},${h.lng}'): h.copyWith(isPlaceFicha: true),
        };
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _predictions = const [];
        _busy = false;
      });
      AppToast.error(context, e, logContext: 'location_search');
    }
  }

  Map<String, GeoPlace> _fallbackById = {};

  Future<void> _selectPrediction(PlacePrediction pred) async {
    setState(() => _busy = true);
    try {
      GeoPlace? place;
      final id = pred.placeId.startsWith('places/')
          ? pred.placeId.substring('places/'.length)
          : pred.placeId;
      if (_places.isConfigured &&
          (id.startsWith('ChIJ') || id.length > 16)) {
        place = await _places.placeDetails(
          placeId: id,
          sessionToken: _sessionToken,
        );
      }
      place ??= _fallbackById[pred.placeId];
      _sessionToken = null;
      if (place == null) {
        if (mounted) {
          setState(() => _busy = false);
          AppToast.show(
            context,
            context.l10n.locationNoMatches,
            error: true,
          );
        }
        return;
      }
      place = place.copyWith(isPlaceFicha: true);
      final point = LatLng(place.lat, place.lng);
      if (!mounted) return;
      setState(() {
        _pin = point;
        _place = place;
        _pinOnlyPlace = null;
        _nearbyPlaces = const [];
        _predictions = const [];
        _hasUserSelection = true;
        _searchCtrl.text = place!.displayName ?? place.name ?? pred.primaryText;
        _hint = null;
        _busy = false;
      });
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(point, 16),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      AppToast.error(context, e, logContext: 'location_select');
    }
  }

  void _selectNearby(GeoPlace place) {
    setState(() {
      _place = place.copyWith(isPlaceFicha: true);
      _pin = LatLng(place.lat, place.lng);
      _hasUserSelection = true;
      _searchCtrl.text = place.name ?? place.displayName ?? '';
      _hint = null;
    });
    unawaited(
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_pin, 17),
      ),
    );
  }

  void _selectPinOnly() {
    final pin = _pinOnlyPlace;
    if (pin == null) return;
    setState(() {
      _place = pin;
      _pin = LatLng(pin.lat, pin.lng);
      _hasUserSelection = true;
      _searchCtrl.text = pin.displayName ?? pin.addressLine ?? '';
      _hint = null;
    });
  }

  Future<void> _setPin(LatLng point) async {
    final now = DateTime.now();
    if (_lastTapAt != null &&
        now.difference(_lastTapAt!) < const Duration(milliseconds: 500)) {
      return;
    }
    _lastTapAt = now;
    setState(() {
      _pin = point;
      _predictions = const [];
      _hint = null;
      _hasUserSelection = true;
    });
    await _onMapPoint(point);
  }

  Future<void> _useMyLocation() async {
    setState(() {
      _locating = true;
      _hint = null;
    });
    final loc = ref.read(deviceLocationProvider);
    if (await loc.access(request: true) == LocationAccess.denied) {
      if (!mounted) return;
      setState(() {
        _hint = context.l10n.locationNeedGps;
        _locating = false;
      });
      return;
    }
    final fix = await loc.tryCurrent(
      accuracy: LocationAccuracy.high,
      request: false,
    );
    if (!mounted) return;
    if (fix == null) {
      setState(() {
        _hint = context.l10n.locationGpsFail;
        _locating = false;
      });
      return;
    }
    try {
      final next = LatLng(fix.lat, fix.lng);
      setState(() => _locating = false);
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(next, 16),
      );
      await _setPin(next);
    } catch (_) {
      setState(() {
        _hint = context.l10n.locationGpsFail;
        _locating = false;
      });
    }
  }

  Future<void> _confirm() async {
    if (!_canConfirm) return;
    if (_place == null ||
        _place!.city == null ||
        _place!.addressLine == null) {
      await _onMapPoint(_pin);
    }
    if (!mounted || !_hasUserSelection) return;
    final place = _place ??
        GeoPlace(lat: _pin.latitude, lng: _pin.longitude);
    Navigator.of(context).pop<GeoPlace>(
      GeoPlace(
        lat: place.isPlaceFicha ? place.lat : _pin.latitude,
        lng: place.isPlaceFicha ? place.lng : _pin.longitude,
        displayName: place.displayName,
        name: place.name,
        city: place.city,
        department: place.department,
        addressLine: place.addressLine ?? place.displayName,
        placeId: place.isPlaceFicha ? place.placeId : null,
        isPlaceFicha: place.isPlaceFicha,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watchAppThemeMode();
    final l10n = context.l10n;
    final providerLabel = Env.hasGoogleMapsKey
        ? l10n.locationProviderGoogle
        : Env.hasGeoapifyKey
            ? l10n.locationProviderFallback
            : l10n.locationProviderNone;
    final showNearbyStrip =
        _nearbyPlaces.isNotEmpty || _pinOnlyPlace != null;

    return Scaffold(
      key: WidgetKeys.locationPicker,
      appBar: AppBar(
        title: Text(l10n.locationPickerTitle),
        actions: [
          TextButton(
            key: WidgetKeys.locationUseAppBar,
            onPressed: _canConfirm ? _confirm : null,
            child: Text(l10n.actionUse),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: l10n.locationPickerSearchHint,
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: FieldActionIcon(
                  icon: Icons.search,
                  tooltip: l10n.actionSearch,
                  loading: _busy,
                  onPressed: _busy
                      ? null
                      : () => _runSearch(_searchCtrl.text),
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _runSearch,
            ),
          ),
          if (_predictions.isNotEmpty)
            Material(
              elevation: 2,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _predictions.length,
                  itemBuilder: (context, index) {
                    final s = _predictions[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined),
                      title: Text(
                        s.primaryText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: s.secondaryText == null
                          ? null
                          : Text(
                              s.secondaryText!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                      onTap: () => _selectPrediction(s),
                    );
                  },
                ),
              ),
            ),
          if (_hint != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                _hint!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            )
          else if (_place?.displayName != null || _place?.name != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                _place!.name ?? _place!.displayName!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (showNearbyStrip)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  if (_pinOnlyPlace != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: _place != null &&
                            !_place!.isPlaceFicha &&
                            _place!.lat == _pinOnlyPlace!.lat &&
                            _place!.lng == _pinOnlyPlace!.lng,
                        label: Text(l10n.locationPinOnly),
                        onSelected: (_) => _selectPinOnly(),
                      ),
                    ),
                  for (final p in _nearbyPlaces)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: _place?.placeId != null &&
                            _place!.placeId == p.placeId,
                        avatar: Icon(
                          Icons.storefront_outlined,
                          size: 16,
                          color: AppColors.muted,
                        ),
                        label: Text(
                          p.name ?? p.displayName ?? l10n.locationNearbyPlace,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onSelected: (_) => _selectNearby(p),
                      ),
                    ),
                ],
              ),
            ),
          if (!_hasUserSelection)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Text(
                l10n.locationMarkMapFirst,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.muted,
                    ),
              ),
            ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _pin,
                zoom: widget.initialLat != null ? 15 : 6,
              ),
              onMapCreated: (c) => _mapController = c,
              onTap: _setPin,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId('pin'),
                  position: _pin,
                  draggable: true,
                  onDragEnd: _setPin,
                ),
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    providerLabel,
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: WidgetKeys.locationMyGps,
                          onPressed: _locating ? null : _useMyLocation,
                          icon: _locating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.my_location),
                          label: Text(l10n.locationMyLocation),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          key: WidgetKeys.locationConfirm,
                          onPressed: _canConfirm ? _confirm : null,
                          icon: const Icon(Icons.check),
                          label: Text(l10n.locationConfirm),
                        ),
                      ),
                    ],
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
