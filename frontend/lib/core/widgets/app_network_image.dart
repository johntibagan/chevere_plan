import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../cache/app_image_cache.dart';
import '../photos/wikimedia_display_url.dart';
import '../photos/wikimedia_session_widths.dart';
import '../theme/app_theme.dart';

/// Decode en memoria: un solo eje, tope 2048 px (equipos de gama media).
enum AppImageQuality {
  /// Covers / avatares: tamaño en pantalla × DPR.
  standard,

  /// Tira de fotos: ~2× el alto visible, mínimo 720 px (nítido sin archivo original).
  photo,

  /// Visor a pantalla completa: lado largo de la pantalla, mínimo 1080 px.
  fullScreen,
}

/// Imagen de red con caché en disco/memoria (límites vía [AppImageCacheManager]).
///
/// Usa [cacheKey] estable (p. ej. id de foto / storage_path) para que al
/// renovar la URL firmada no se descargue de nuevo el mismo archivo.
/// URLs de Wikimedia Commons se piden como thumb; si fallan, sube de resolución
/// (o al más grande en pantalla completa) y al final el original.
/// Al aparecer la foto: fade corto (~180 ms), sin shimmer/blur-hash.
///
/// Wikimedia: [WikimediaSessionWidths] recuerda el último ancho OK en la sesión.
/// Si hay un thumb menor ya en disco/sesión y se pide mayor calidad (tira→visor),
/// pinta el menor al toque y sube al preferido con fade (mejora progresiva).
class AppNetworkImage extends StatefulWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.cacheKey,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.showLoadingIndicator = false,
    this.quality = AppImageQuality.standard,
  });

  final String url;

  /// Clave estable de caché (recomendado: `photo.id` o `storage_path`).
  final String? cacheKey;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  /// Si false (default), placeholder es un bloque de color (más liviano).
  final bool showLoadingIndicator;
  final AppImageQuality quality;

  /// Ancho de thumb Wikimedia según uso en UI (lista permitida del host).
  static int wikiThumbWidthFor(AppImageQuality quality) {
    return switch (quality) {
      AppImageQuality.standard => 500,
      AppImageQuality.photo => 800,
      AppImageQuality.fullScreen => 1280,
    };
  }

  @override
  State<AppNetworkImage> createState() => _AppNetworkImageState();
}

class _AppNetworkImageState extends State<AppNetworkImage> {
  static const _maxDecode = 2048;

  /// Fade al mostrar la imagen real (Paso 4 rendimiento).
  static const _fadeIn = Duration(milliseconds: 180);
  static const _fadeOut = Duration(milliseconds: 120);

  /// Índice en la escalera de reintentos Wikimedia (capa “alta”).
  late int _wikiAttempt;

  /// Thumb menor ya disponible (sesión/disco) mientras llega el preferido.
  int? _lowWidth;

  @override
  void initState() {
    super.initState();
    _resetWikiState();
  }

  @override
  void didUpdateWidget(covariant AppNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.cacheKey != widget.cacheKey ||
        oldWidget.quality != widget.quality) {
      _resetWikiState();
    }
  }

  String get _wikiBase => WikimediaSessionWidths.baseKey(
        cacheKey: widget.cacheKey,
        sourceUrl: widget.url,
      );

  int get _preferredWidth =>
      AppNetworkImage.wikiThumbWidthFor(widget.quality);

  List<int?> _wikiLadder() {
    return wikimediaRetryWidths(
      preferredWidth: _preferredWidth,
      fullScreen: widget.quality == AppImageQuality.fullScreen,
    );
  }

  bool get _wiki => isWikimediaUploadUrl(widget.url);

  /// Mejora progresiva: hay menor en caché/sesión y pedimos más ancho.
  bool get _progressive =>
      _wiki && _lowWidth != null && _lowWidth! < _preferredWidth;

  void _resetWikiState() {
    _lowWidth = null;
    if (!_wiki) {
      _wikiAttempt = 0;
      return;
    }

    final preferred = _preferredWidth;
    final mem = WikimediaSessionWidths.instance;
    if (mem.has(_wikiBase)) {
      final known = mem.width(_wikiBase);
      if (known != null && known < preferred) {
        // Tira→visor (u otra subida de calidad): mostrar lo conocido ya.
        _lowWidth = known;
        _wikiAttempt = 0;
      } else {
        _wikiAttempt = mem.startAttemptIndex(_wikiBase, _wikiLadder());
      }
    } else {
      _wikiAttempt = 0;
    }
    unawaited(_probeDiskForLow(preferred));
  }

  /// Busca en disco el mayor thumb &lt; [preferred] (p. ej. @w800 con preferido 1280).
  Future<void> _probeDiskForLow(int preferred) async {
    if (!_wiki) return;
    int? best;
    for (final w in kWikimediaThumbWidths.reversed) {
      if (w >= preferred) continue;
      final key = wikimediaAttempt(
        sourceUrl: widget.url,
        cacheKey: widget.cacheKey,
        widthPx: w,
      ).cacheKey;
      try {
        final info =
            await AppImageCacheManager.instance.getFileFromCache(key);
        if (info != null) {
          best = w;
          break;
        }
      } catch (_) {}
    }
    if (!mounted || best == null) return;
    if (_lowWidth != null && best <= _lowWidth!) return;
    setState(() {
      _lowWidth = best;
      // Subir siempre al preferido de esta quality (capa alta).
      _wikiAttempt = 0;
    });
  }

  void _rememberWikiSuccess(int? widthPx) {
    if (!_wiki) return;
    WikimediaSessionWidths.instance.remember(_wikiBase, widthPx);
  }

  int _decodeSide(BuildContext context, double logical, {required int minPx}) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final scale = switch (widget.quality) {
      AppImageQuality.photo => 2.0,
      AppImageQuality.fullScreen => 1.0,
      AppImageQuality.standard => 1.0,
    };
    return (logical * dpr * scale).round().clamp(minPx, _maxDecode);
  }

  int _screenLongSide(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return (size.longestSide * dpr).round().clamp(1080, _maxDecode);
  }

  void _advanceWikiFallback(List<int?> ladder) {
    if (_wikiAttempt >= ladder.length - 1) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_wikiAttempt >= ladder.length - 1) return;
      setState(() => _wikiAttempt++);
    });
  }

  ({int? memW, int? memH}) _memCacheSize(BuildContext context) {
    if (widget.quality == AppImageQuality.fullScreen) {
      return (memW: _screenLongSide(context), memH: null);
    }
    if (widget.fit == BoxFit.cover &&
        widget.width != null &&
        widget.height != null) {
      final side =
          widget.width! > widget.height! ? widget.width! : widget.height!;
      return (memW: _decodeSide(context, side, minPx: 32), memH: null);
    }
    if (widget.fit == BoxFit.fitHeight && widget.height != null) {
      return (
        memW: null,
        memH: _decodeSide(
          context,
          widget.height!,
          minPx: widget.quality == AppImageQuality.photo ? 720 : 32,
        ),
      );
    }
    if (widget.fit == BoxFit.fitWidth && widget.width != null) {
      return (
        memW: _decodeSide(context, widget.width!, minPx: 32),
        memH: null,
      );
    }
    if (widget.width != null) {
      return (
        memW: _decodeSide(context, widget.width!, minPx: 32),
        memH: null,
      );
    }
    if (widget.height != null) {
      return (
        memW: null,
        memH: _decodeSide(
          context,
          widget.height!,
          minPx: widget.quality == AppImageQuality.photo ? 720 : 32,
        ),
      );
    }
    return (memW: _screenLongSide(context), memH: null);
  }

  Widget _cachedNetwork({
    required String displayUrl,
    required String? effectiveKey,
    required int? widthPx,
    required int? memW,
    required int? memH,
    required FilterQuality filterQuality,
    required Widget placeholder,
    required Widget errorBox,
    required List<int?> ladder,
    required int attemptIdx,
    required bool fadeIn,
    required bool transparentPlaceholder,
    /// Error final sin icono (capa baja o alta sobre baja).
    required bool hideFinalError,
  }) {
    return CachedNetworkImage(
      imageUrl: displayUrl,
      cacheKey: effectiveKey,
      cacheManager: AppImageCacheManager.instance,
      httpHeaders: const {
        'User-Agent': AppImageCacheManager.userAgent,
        'Accept': 'image/*,*/*;q=0.8',
      },
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      fadeInDuration: fadeIn ? _fadeIn : Duration.zero,
      fadeOutDuration: fadeIn ? _fadeOut : Duration.zero,
      memCacheWidth: memW,
      memCacheHeight: memH,
      filterQuality: filterQuality,
      placeholder: (context, _) =>
          transparentPlaceholder ? const SizedBox.shrink() : placeholder,
      imageBuilder: (context, imageProvider) {
        if (_wiki) {
          _rememberWikiSuccess(widthPx);
        }
        return Image(
          image: imageProvider,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          filterQuality: filterQuality,
          alignment: Alignment.center,
          gaplessPlayback: true,
        );
      },
      errorWidget: (context, _, _) {
        if (_wiki && attemptIdx < ladder.length - 1) {
          _advanceWikiFallback(ladder);
          return transparentPlaceholder
              ? const SizedBox.shrink()
              : placeholder;
        }
        if (hideFinalError) {
          return const SizedBox.shrink();
        }
        return errorBox;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mem = _memCacheSize(context);
    final memW = mem.memW;
    final memH = mem.memH;

    final ladder = _wiki ? _wikiLadder() : const <int?>[null];
    final attemptIdx =
        _wiki ? _wikiAttempt.clamp(0, ladder.length - 1) : 0;
    final widthPx = _wiki ? ladder[attemptIdx] : null;

    late final String displayUrl;
    late final String? effectiveKey;
    if (_wiki) {
      final attempt = wikimediaAttempt(
        sourceUrl: widget.url,
        cacheKey: widget.cacheKey,
        widthPx: widthPx,
      );
      displayUrl = attempt.displayUrl;
      effectiveKey = attempt.cacheKey;
    } else {
      displayUrl = widget.url;
      effectiveKey = widget.cacheKey;
    }

    final placeholderW =
        widget.width ?? (widget.height != null ? widget.height! * 0.72 : null);
    final placeholder = SizedBox(
      width: placeholderW,
      height: widget.height,
      child: ColoredBox(
        color: AppColors.surfaceElevated,
        child: widget.showLoadingIndicator
            ? Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : null,
      ),
    );

    final errorBox = SizedBox(
      width: placeholderW,
      height: widget.height,
      child: ColoredBox(
        color: AppColors.surfaceElevated,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppColors.muted,
        ),
      ),
    );

    final filterQuality = widget.quality == AppImageQuality.standard
        ? FilterQuality.low
        : FilterQuality.medium;

    final high = _cachedNetwork(
      displayUrl: displayUrl,
      effectiveKey: effectiveKey,
      widthPx: widthPx,
      memW: memW,
      memH: memH,
      filterQuality: filterQuality,
      placeholder: placeholder,
      errorBox: errorBox,
      ladder: ladder,
      attemptIdx: attemptIdx,
      fadeIn: true,
      transparentPlaceholder: _progressive,
      hideFinalError: _progressive,
    );

    Widget image = high;
    if (_progressive) {
      final lowAttempt = wikimediaAttempt(
        sourceUrl: widget.url,
        cacheKey: widget.cacheKey,
        widthPx: _lowWidth,
      );
      final low = _cachedNetwork(
        displayUrl: lowAttempt.displayUrl,
        effectiveKey: lowAttempt.cacheKey,
        widthPx: _lowWidth,
        memW: memW,
        memH: memH,
        filterQuality: filterQuality,
        placeholder: placeholder,
        errorBox: errorBox,
        ladder: <int?>[_lowWidth],
        attemptIdx: 0,
        fadeIn: false,
        transparentPlaceholder: false,
        hideFinalError: true,
      );
      image = Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: [
          low,
          high,
        ],
      );
    }

    if (widget.borderRadius == null) return image;
    return ClipRRect(borderRadius: widget.borderRadius!, child: image);
  }
}
