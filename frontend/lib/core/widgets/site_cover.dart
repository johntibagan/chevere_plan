import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_network_image.dart';

/// Familia visual de portada vacía (categoría **padre** del catálogo).
enum SiteCoverFamily {
  gastronomy,
  lodging,
  nature,
  sport,
  culture,
  entertainment,
  shopping,
  other;

  Color get accent {
    switch (this) {
      case SiteCoverFamily.gastronomy:
        return AppColors.catGastro;
      case SiteCoverFamily.lodging:
        return AppColors.coverLodging;
      case SiteCoverFamily.nature:
        return AppColors.coverNature;
      case SiteCoverFamily.sport:
        return AppColors.coverSport;
      case SiteCoverFamily.culture:
        return AppColors.catCult;
      case SiteCoverFamily.entertainment:
        return AppColors.catEnt;
      case SiteCoverFamily.shopping:
        return AppColors.catComp;
      case SiteCoverFamily.other:
        return AppColors.muted;
    }
  }

  IconData get icon {
    switch (this) {
      case SiteCoverFamily.gastronomy:
        return Icons.restaurant_rounded;
      case SiteCoverFamily.lodging:
        return Icons.hotel_rounded;
      case SiteCoverFamily.nature:
        return Icons.park_rounded;
      case SiteCoverFamily.sport:
        return Icons.sports_soccer_rounded;
      case SiteCoverFamily.culture:
        return Icons.account_balance_rounded;
      case SiteCoverFamily.entertainment:
        return Icons.music_note_rounded;
      case SiteCoverFamily.shopping:
        return Icons.shopping_bag_rounded;
      case SiteCoverFamily.other:
        return Icons.place_rounded;
    }
  }

  /// Ilustración por categoría **padre**. Sin pista → Otros (no se inventa
  /// otra familia por id: card y ficha tienen que coincidir).
  static SiteCoverFamily resolve({String? hint, String? seed}) {
    return fromLabel(hint) ?? SiteCoverFamily.other;
  }

  static SiteCoverFamily? fromLabel(String? raw) {
    final n = (raw ?? '').toLowerCase().trim();
    if (n.isEmpty) return null;
    if (n.contains('gastro') ||
        n.contains('comida') ||
        n.contains('restaura') ||
        n.contains('bar') ||
        n.contains('cafe') ||
        n.contains('café')) {
      return SiteCoverFamily.gastronomy;
    }
    if (n.contains('aloj') ||
        n.contains('hotel') ||
        n.contains('hostal') ||
        n.contains('glamping') ||
        n.contains('posada')) {
      return SiteCoverFamily.lodging;
    }
    if (n.contains('plaza') ||
        n.contains('cult') ||
        n.contains('museo') ||
        n.contains('iglesia') ||
        n.contains('patrimon') ||
        n.contains('pueblo') ||
        n.contains('galer')) {
      return SiteCoverFamily.culture;
    }
    if (n.contains('natur') ||
        n.contains('parque') ||
        n.contains('playa') ||
        n.contains('sendero') ||
        n.contains('cascada') ||
        n.contains('mirador') ||
        n.contains('termal')) {
      return SiteCoverFamily.nature;
    }
    if (n.contains('deporte') ||
        n.contains('cancha') ||
        n.contains('tejo') ||
        n.contains('gimnas') ||
        n.contains('piscina')) {
      return SiteCoverFamily.sport;
    }
    if (n.contains('entreten') ||
        n.contains('cine') ||
        n.contains('festival') ||
        n.contains('concierto') ||
        n.contains('musica') ||
        n.contains('música') ||
        n.contains('evento') ||
        n.contains('spa')) {
      return SiteCoverFamily.entertainment;
    }
    if (n.contains('compra') ||
        n.contains('mercado') ||
        n.contains('tienda') ||
        n.contains('souvenir')) {
      return SiteCoverFamily.shopping;
    }
    if (n.contains('serv') || n.contains('otro') || n.contains('terminal')) {
      return SiteCoverFamily.other;
    }
    return null;
  }
}

/// Portada de tarjeta: foto de red o ilustración por defecto (sin hueco vacío).
class SiteCover extends StatelessWidget {
  const SiteCover({
    super.key,
    this.imageUrl,
    this.cacheKey,
    this.categoryHint,
    this.seed,
  });

  final String? imageUrl;
  final String? cacheKey;
  /// Nombre o slug de categoría (mejor si es la **padre**).
  final String? categoryHint;
  /// Id estable (sitio/plan) para variar cuando no hay categoría.
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.antiAlias,
      children: [
        DefaultSiteCover(categoryHint: categoryHint),
        if (url != null && url.isNotEmpty)
          AppNetworkImage(
            url: url,
            cacheKey: cacheKey,
            fit: BoxFit.cover,
          ),
      ],
    );
  }
}

/// Degradado sobre la portada (títulos/meta en la foto). Una sola receta.
class SiteCoverScrim extends StatelessWidget {
  const SiteCoverScrim({super.key, this.bottomOpacity = 0.65});

  final double bottomOpacity;

  @override
  Widget build(BuildContext context) {
    final bottom = Color.fromRGBO(0, 0, 0, bottomOpacity);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, bottom],
        ),
      ),
    );
  }
}

/// Ilustración de marca cuando el sitio no tiene foto.
///
/// Escala sola: mini (~40), compacta (grid/plan ~96–100), amplia (carrusel/hero).
class DefaultSiteCover extends StatelessWidget {
  const DefaultSiteCover({super.key, this.categoryHint, this.seed});

  final String? categoryHint;
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final family = SiteCoverFamily.resolve(hint: categoryHint);
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final dense = side > 0 && side < 52;
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.antiAlias,
          children: [
            ColoredBox(color: AppColors.surface),
            CustomPaint(
              painter: _EditorialCoverPainter(family: family, dense: dense),
            ),
            Align(
              alignment: dense ? Alignment.center : const Alignment(0.55, 0.15),
              child: Icon(
                family.icon,
                size: dense
                    ? (side * 0.46).clamp(14.0, 20.0)
                    : (side * 0.28).clamp(22.0, 48.0),
                color: family.accent.withValues(alpha: dense ? 0.85 : 0.42),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EditorialCoverPainter extends CustomPainter {
  const _EditorialCoverPainter({required this.family, required this.dense});

  final SiteCoverFamily family;
  final bool dense;

  @override
  void paint(Canvas canvas, Size size) {
    // Los blobs se centran fuera del rectángulo; sin clip pintan encima del
    // AppBar (corazón) y del TabBar (Info) en la ficha.
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    final accent = family.accent;
    final g = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.surfaceElevated,
          Color.lerp(AppColors.background, accent, 0.18)!,
          AppColors.background,
        ],
        stops: const [0, 0.45, 1],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, g);

    // Motivo de categoría primero; círculos decorativos encima (bajo el icono).
    if (!dense) {
      switch (family) {
        case SiteCoverFamily.gastronomy:
          _rings(canvas, size, accent);
        case SiteCoverFamily.lodging:
          _blinds(canvas, size, accent);
        case SiteCoverFamily.nature:
          _hills(canvas, size, accent);
        case SiteCoverFamily.sport:
          _stripes(canvas, size, accent);
        case SiteCoverFamily.culture:
          _diamonds(canvas, size, accent);
        case SiteCoverFamily.entertainment:
          _dots(canvas, size, accent);
        case SiteCoverFamily.shopping:
          _chevrons(canvas, size, accent);
        case SiteCoverFamily.other:
          _grid(canvas, size, accent);
      }
    }

    if (dense) {
      canvas.drawCircle(
        Offset(size.width * 0.72, size.height * 0.28),
        size.shortestSide * 0.35,
        Paint()..color = accent.withValues(alpha: 0.12),
      );
    } else {
      canvas.drawCircle(
        Offset(size.width * 0.88, size.height * -0.05),
        size.shortestSide * 0.55,
        Paint()..color = accent.withValues(alpha: 0.10),
      );
      canvas.drawCircle(
        Offset(size.width * 0.08, size.height * 1.05),
        size.shortestSide * 0.42,
        Paint()..color = accent.withValues(alpha: 0.08),
      );
    }

    canvas.restore();
  }

  void _rings(Canvas canvas, Size size, Color accent) {
    final c = Offset(size.width * 0.22, size.height * 0.78);
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(
        c,
        size.shortestSide * 0.12 * i,
        Paint()
          ..color = accent.withValues(alpha: 0.07)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  void _blinds(Canvas canvas, Size size, Color accent) {
    final p = Paint()
      ..color = accent.withValues(alpha: 0.06)
      ..strokeWidth = 3;
    for (var y = size.height * 0.2; y < size.height; y += 9) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  void _hills(Canvas canvas, Size size, Color accent) {
    final hill = Paint()..color = accent.withValues(alpha: 0.10);
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.48,
        size.width * 0.55,
        size.height * 0.68,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height * 0.86,
        size.width,
        size.height * 0.62,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, hill);
  }

  void _stripes(Canvas canvas, Size size, Color accent) {
    final p = Paint()
      ..color = accent.withValues(alpha: 0.07)
      ..strokeWidth = 8;
    for (var x = -size.height; x < size.width + size.height; x += 18) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        p,
      );
    }
  }

  void _diamonds(Canvas canvas, Size size, Color accent) {
    final p = Paint()
      ..color = accent.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const step = 18.0;
    for (var y = 0.0; y < size.height + step; y += step) {
      for (var x = 0.0; x < size.width + step; x += step) {
        final path = Path()
          ..moveTo(x, y + step / 2)
          ..lineTo(x + step / 2, y)
          ..lineTo(x + step, y + step / 2)
          ..lineTo(x + step / 2, y + step)
          ..close();
        canvas.drawPath(path, p);
      }
    }
  }

  void _dots(Canvas canvas, Size size, Color accent) {
    final p = Paint()..color = accent.withValues(alpha: 0.14);
    const step = 14.0;
    for (var y = 8.0; y < size.height; y += step) {
      for (var x = 8.0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.6, p);
      }
    }
  }

  void _chevrons(Canvas canvas, Size size, Color accent) {
    final p = Paint()
      ..color = accent.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    for (var y = 10.0; y < size.height; y += 16) {
      final path = Path();
      var up = true;
      path.moveTo(0, y);
      for (var x = 0.0; x <= size.width; x += 10) {
        path.lineTo(x, y + (up ? -5 : 5));
        up = !up;
      }
      canvas.drawPath(path, p);
    }
  }

  void _grid(Canvas canvas, Size size, Color accent) {
    final p = Paint()
      ..color = accent.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    const step = 16.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _EditorialCoverPainter oldDelegate) =>
      oldDelegate.family != family || oldDelegate.dense != dense;
}

/// Corazón Figma (arriba derecha). Relleno = favorito.
class CardHeartBadge extends StatelessWidget {
  const CardHeartBadge({super.key, required this.saved});

  final bool saved;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.coverScrim,
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 13,
          color: saved ? AppColors.accent : AppColors.onImage,
        ),
      ),
    );
  }
}
