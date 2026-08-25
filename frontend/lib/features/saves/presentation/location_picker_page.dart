import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/config/env.dart';
import '../../../core/di/providers.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/testing/widget_keys.dart';
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
  String? _sessionToken;
  bool _locating = false;
  bool _busy = false;
  String? _hint;
  DateTime? _lastTapAt;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _pin = LatLng(widget.initialLat!, widget.initialLng!);
      WidgetsBinding.instance.addPostFrameCallback((_) => _reverse(_pin));
    } else {
      _pin = _colombiaCenter;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hint == null &&
        !Env.hasGoogleMapsKey &&
        !Env.hasGeoapifyKey) {
      _hint = context.l10n.locationMapsUnavailable;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _reverse(LatLng point) async {
    setState(() => _busy = true);
    try {
      final place = await _geocoder.reverse(
        lat: point.latitude,
        lng: point.longitude,
      );
      if (!mounted) return;
      setState(() {
        _place = place ??
            GeoPlace(lat: point.latitude, lng: point.longitude);
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _place = GeoPlace(lat: point.latitude, lng: point.longitude);
        _busy = false;
      });
      AppToast.error(context, e, logContext: 'location_reverse');
    }
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
        // Guardamos coords en un mapa paralelo vía placeId sintético.
        _fallbackById = {
          for (final h in hits)
            (h.placeId ?? '${h.lat},${h.lng}'): h,
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
      final point = LatLng(place.lat, place.lng);
      if (!mounted) return;
      setState(() {
        _pin = point;
        _place = place;
        _predictions = const [];
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
    });
    await _reverse(point);
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
    if (_place == null ||
        _place!.city == null ||
        _place!.addressLine == null) {
      await _reverse(_pin);
    }
    if (!mounted) return;
    final place = _place ??
        GeoPlace(lat: _pin.latitude, lng: _pin.longitude);
    Navigator.of(context).pop<GeoPlace>(
      GeoPlace(
        lat: _pin.latitude,
        lng: _pin.longitude,
        displayName: place.displayName,
        name: place.name,
        city: place.city,
        department: place.department,
        addressLine: place.addressLine ?? place.displayName,
        placeId: place.placeId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final providerLabel = Env.hasGoogleMapsKey
        ? l10n.locationProviderGoogle
        : Env.hasGeoapifyKey
            ? l10n.locationProviderFallback
            : l10n.locationProviderNone;

    return Scaffold(
      key: WidgetKeys.locationPicker,
      appBar: AppBar(
        title: Text(l10n.locationPickerTitle),
        actions: [
          TextButton(
            key: WidgetKeys.locationUseAppBar,
            onPressed: _confirm,
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
              // Sin onChanged: no Autocomplete por tecla.
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
          if (_place?.displayName != null || _hint != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                _hint ?? _place!.displayName!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _hint != null
                          ? Theme.of(context).colorScheme.error
                          : null,
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
                          onPressed: _confirm,
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
