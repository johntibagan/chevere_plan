import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_network_image.dart';

/// Portada de tarjeta: foto de red o ilustración por defecto (sin hueco vacío).
class SiteCover extends StatelessWidget {
  const SiteCover({
    super.key,
    this.imageUrl,
    this.cacheKey,
  });

  final String? imageUrl;
  final String? cacheKey;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    return Stack(
      fit: StackFit.expand,
      children: [
        const DefaultSiteCover(),
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

/// Paisaje oscuro de relleno (Figma: siempre hay foto; si no hay, esta).
class DefaultSiteCover extends StatelessWidget {
  const DefaultSiteCover({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF243044),
                Color(0xFF1A3D32),
                Color(0xFF3A2E1A),
              ],
            ),
          ),
        ),
        CustomPaint(painter: _DefaultCoverPainter()),
        Center(
          child: Icon(
            Icons.landscape_rounded,
            size: 36,
            color: Color(0x66FFBB33),
          ),
        ),
      ],
    );
  }
}

class _DefaultCoverPainter extends CustomPainter {
  const _DefaultCoverPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()..color = const Color(0x22FFBB33);
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.22),
      size.shortestSide * 0.18,
      sky,
    );
    final hill = Paint()..color = const Color(0x33000000);
    final p = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.48,
        size.width * 0.7,
        size.height * 0.7,
      )
      ..lineTo(size.width, size.height * 0.62)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p, hill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Corazón Figma (arriba derecha). Relleno = favorito.
class CardHeartBadge extends StatelessWidget {
  const CardHeartBadge({super.key, required this.saved});

  final bool saved;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0x66000000),
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
