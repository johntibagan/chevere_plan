import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Puente del shell: abrir menú lateral + foto/inicial visibles en cabeceras.
class ShellMenuBridge extends ChangeNotifier {
  String _initial = 'U';
  String? _avatarUrl;
  VoidCallback? _openMoreMenu;

  String get initial => _initial;
  String? get avatarUrl => _avatarUrl;

  void bindOpenMoreMenu(VoidCallback open) {
    _openMoreMenu = open;
  }

  void openMoreMenu() => _openMoreMenu?.call();

  void updateAccount({required String initial, String? avatarUrl}) {
    final nextInitial = initial.trim().isEmpty ? 'U' : initial;
    final nextUrl = avatarUrl?.trim();
    final url = (nextUrl == null || nextUrl.isEmpty) ? null : nextUrl;
    if (_initial == nextInitial && _avatarUrl == url) return;
    _initial = nextInitial;
    _avatarUrl = url;
    notifyListeners();
  }
}

final shellMenuBridgeProvider =
    ChangeNotifierProvider<ShellMenuBridge>((ref) => ShellMenuBridge());
