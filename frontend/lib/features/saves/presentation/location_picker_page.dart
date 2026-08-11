import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/config/env.dart';
import '../../../core/errors/user_facing_error.dart';
import '../data/geo_place.dart';
import '../data/place_geocoder.dart';

/// Mapa OSM + búsqueda Geoapify (autocomplete). Devuelve [GeoPlace] al confirmar.
class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  final double? initialLat;
  final double? initialLng;

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  static const _colombiaCenter = LatLng(4.5709, -74.2973);

  final _geocoder = PlaceGeocoder();
  final _searchCtrl = TextEditingController();
  late final MapController _mapController;

  late LatLng _pin;
  GeoPlace? _place;
  List<GeoPlace> _suggestions = const [];
  bool _locating = false;
  bool _busy = false;
  String? _hint;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.initialLat != null && widget.initialLng != null) {
      _pin = LatLng(widget.initialLat!, widget.initialLng!);
      _reverse(_pin);
    } else {
      _pin = _colombiaCenter;
    }
    if (!Env.hasGeoapifyKey) {
      _hint =
          'Falta GEOAPIFY_API_KEY en .env — la búsqueda usará un fallback limitado.';
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
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
        _hint = userFacingError(e);
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (value.trim().length < 2) {
        if (mounted) setState(() => _suggestions = const []);
        return;
      }
      setState(() {
        _busy = true;
        _hint = null;
      });
      try {
        final hits = await _geocoder.search(
          value,
          biasLat: _pin.latitude,
          biasLng: _pin.longitude,
        );
        if (!mounted) return;
        setState(() {
          _suggestions = hits;
          _busy = false;
          if (hits.isEmpty) {
            _hint = 'Sin coincidencias. Prueba otro nombre o toca el mapa.';
          }
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _suggestions = const [];
          _busy = false;
          _hint = userFacingError(e);
        });
      }
    });
  }

  Future<void> _selectSuggestion(GeoPlace place) async {
    final point = LatLng(place.lat, place.lng);
    setState(() {
      _pin = point;
      _place = place;
      _suggestions = const [];
      _searchCtrl.text = place.displayName ?? place.name ?? '';
      _hint = null;
    });
    _mapController.move(point, 16);
  }

  Future<void> _setPin(LatLng point) async {
    setState(() {
      _pin = point;
      _suggestions = const [];
      _hint = null;
    });
    await _reverse(point);
  }

  Future<void> _useMyLocation() async {
    setState(() {
      _locating = true;
      _hint = null;
    });
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _hint = 'Activa la ubicación para centrar el mapa en ti.';
          _locating = false;
        });
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final next = LatLng(pos.latitude, pos.longitude);
      setState(() => _locating = false);
      _mapController.move(next, 16);
      await _setPin(next);
    } catch (_) {
      setState(() {
        _hint = 'No se pudo obtener tu ubicación. Busca o toca el mapa.';
        _locating = false;
      });
    }
  }

  void _confirm() {
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
        addressLine: place.addressLine,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegir ubicación'),
        actions: [
          TextButton(onPressed: _confirm, child: const Text('Usar')),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar lugar, dirección, ciudad…',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: _busy
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : (_searchCtrl.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _suggestions = const []);
                            },
                          )),
              ),
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
            ),
          ),
          if (_suggestions.isNotEmpty)
            Material(
              elevation: 2,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final s = _suggestions[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined),
                      title: Text(
                        s.name ?? s.displayName ?? 'Lugar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        s.displayName ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _selectSuggestion(s),
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
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _pin,
                initialZoom: widget.initialLat != null ? 15 : 6,
                onTap: (tap, point) => _setPin(point),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.chevere.plan',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pin,
                      width: 48,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: Icon(
                        Icons.location_on,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ],
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
                    _geocoder.usingGeoapify
                        ? 'Búsqueda: Geoapify · mapa: OpenStreetMap'
                        : 'Búsqueda: fallback · configura GEOAPIFY_API_KEY',
                    style: Theme.of(context).textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
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
                          label: const Text('Mi ubicación'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _confirm,
                          icon: const Icon(Icons.check),
                          label: const Text('Confirmar'),
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
