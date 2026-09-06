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
/// Wikimedia: [WikimediaSessionWidths] recuerda el último ancho OK en la sesión
/// para no redescubrir la escalera al recrear el widget (tira ↔ visor, swipe).
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

  /// Índice en la escalera de reintentos Wikimedia (0 = preferido).
  late int _wikiAttempt;

  @override
  void initState() {
    super.initState();
    _wikiAttempt = _startAttemptFromSession();
  }

  @override
  void didUpdateWidget(covariant AppNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.cacheKey != widget.cacheKey ||
        oldWidget.quality != widget.quality) {
      _wikiAttempt = _startAttemptFromSession();
    }
  }

  String get _wikiBase => WikimediaSessionWidths.baseKey(
        cacheKey: widget.cacheKey,
        sourceUrl: widget.url,
      );

  List<int?> _wikiLadder() {
    final preferred = AppNetworkImage.wikiThumbWidthFor(widget.quality);
    return wikimediaRetryWidths(
      preferredWidth: preferred,
      fullScreen: widget.quality == AppImageQuality.fullScreen,
    );
  }

  int _startAttemptFromSession() {
    if (!isWikimediaUploadUrl(widget.url)) return 0;
    return WikimediaSessionWidths.instance.startAttemptIndex(
      _wikiBase,
      _wikiLadder(),
    );
  }

  void _rememberWikiSuccess(int? widthPx) {
    if (!isWikimediaUploadUrl(widget.url)) return;
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

  @override
  Widget build(BuildContext context) {
    // Solo un eje de decode: ambos a la vez distorsionan la foto.
    final int? memW;
    final int? memH;
    if (widget.quality == AppImageQuality.fullScreen) {
      memW = _screenLongSide(context);
      memH = null;
    } else if (widget.fit == BoxFit.cover &&
        widget.width != null &&
        widget.height != null) {
      final side =
          widget.width! > widget.height! ? widget.width! : widget.height!;
      memW = _decodeSide(context, side, minPx: 32);
      memH = null;
    } else if (widget.fit == BoxFit.fitHeight && widget.height != null) {
      memW = null;
      memH = _decodeSide(
        context,
        widget.height!,
        minPx: widget.quality == AppImageQuality.photo ? 720 : 32,
      );
    } else if (widget.fit == BoxFit.fitWidth && widget.width != null) {
      memW = _decodeSide(context, widget.width!, minPx: 32);
      memH = null;
    } else if (widget.width != null) {
      memW = _decodeSide(context, widget.width!, minPx: 32);
      memH = null;
    } else if (widget.height != null) {
      memW = null;
      memH = _decodeSide(
        context,
        widget.height!,
        minPx: widget.quality == AppImageQuality.photo ? 720 : 32,
      );
    } else {
      memW = _screenLongSide(context);
      memH = null;
    }

    final wiki = isWikimediaUploadUrl(widget.url);
    final ladder = wiki ? _wikiLadder() : const <int?>[null];
    final attemptIdx =
        wiki ? _wikiAttempt.clamp(0, ladder.length - 1) : 0;
    final widthPx = wiki ? ladder[attemptIdx] : null;

    late final String displayUrl;
    late final String? effectiveKey;
    if (wiki) {
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

    final image = CachedNetworkImage(
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
      fadeInDuration: _fadeIn,
      fadeOutDuration: _fadeOut,
      memCacheWidth: memW,
      memCacheHeight: memH,
      filterQuality: filterQuality,
      placeholder: (context, _) => placeholder,
      imageBuilder: (context, imageProvider) {
        if (wiki) {
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
        if (wiki && attemptIdx < ladder.length - 1) {
          _advanceWikiFallback(ladder);
          return placeholder;
        }
        return errorBox;
      },
    );

    if (widget.borderRadius == null) return image;
    return ClipRRect(borderRadius: widget.borderRadius!, child: image);
  }
}
