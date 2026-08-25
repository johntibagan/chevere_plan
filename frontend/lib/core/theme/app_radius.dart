import 'package:flutter/material.dart';

/// Radios de borde (Figma / Material del proyecto).
abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const pill = 999.0;

  static BorderRadius circular(double r) => BorderRadius.circular(r);

  static BorderRadius get smAll => circular(sm);
  static BorderRadius get mdAll => circular(md);
  static BorderRadius get lgAll => circular(lg);
  static BorderRadius get xlAll => circular(xl);
  static BorderRadius get pillAll => circular(pill);
}
