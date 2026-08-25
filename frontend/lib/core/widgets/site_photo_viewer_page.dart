import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../formatters/date_format.dart';
import '../l10n/context_l10n.dart';
import '../theme/app_theme.dart';
import 'app_network_image.dart';
import 'site_photo_overflow_button.dart';

class SitePhotoViewItem {
  const SitePhotoViewItem({
    required this.id,
    required this.url,
    required this.cacheKey,
    this.uploaderName,
    this.uploadedAt,
    this.canDelete = false,
    this.canSetCover = false,
    this.isCover = false,
  });

  final String id;
  final String url;
  final String cacheKey;
  final String? uploaderName;
  final DateTime? uploadedAt;
  final bool canDelete;
  final bool canSetCover;
  final bool isCover;
}

/// Visor a pantalla completa: foto, autor/fecha, menú ⋮.
class SitePhotoViewerPage extends StatefulWidget {
  const SitePhotoViewerPage({
    super.key,
    required this.photos,
    this.initialIndex = 0,
    this.onMenu,
  });

  final List<SitePhotoViewItem> photos;
  final int initialIndex;
  final void Function(SitePhotoViewItem item, String action)? onMenu;

  static Future<void> open(
    BuildContext context, {
    required List<SitePhotoViewItem> photos,
    int initialIndex = 0,
    void Function(SitePhotoViewItem item, String action)? onMenu,
  }) {
    if (photos.isEmpty) return Future.value();
    final i = initialIndex.clamp(0, photos.length - 1);
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SitePhotoViewerPage(
          photos: photos,
          initialIndex: i,
          onMenu: onMenu,
        ),
      ),
    );
  }

  @override
  State<SitePhotoViewerPage> createState() => _SitePhotoViewerPageState();
}

class _SitePhotoViewerPageState extends State<SitePhotoViewerPage> {
  late final PageController _page;
  late int _index;
  late String? _coverId;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.photos.length - 1);
    _page = PageController(initialPage: _index);
    String? cover;
    for (final p in widget.photos) {
      if (p.isCover) {
        cover = p.id;
        break;
      }
    }
    _coverId = cover;
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  SitePhotoViewItem get _current => widget.photos[_index];

  void _onMenu(String action) {
    final item = _current;
    if (action == 'cover') {
      setState(() => _coverId = item.id);
    }
    if (action == 'delete') {
      Navigator.of(context).pop();
    }
    widget.onMenu?.call(item, action);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = widget.photos.length;
    final item = _current;
    final name = item.uploaderName?.trim();
    final when = item.uploadedAt;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: _page,
                itemCount: total,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final photo = widget.photos[i];
                  final size = MediaQuery.sizeOf(context);
                  return InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                      child: AppNetworkImage(
                        url: photo.url,
                        cacheKey: photo.cacheKey,
                        fit: BoxFit.contain,
                        quality: AppImageQuality.fullScreen,
                        showLoadingIndicator: true,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: 4,
                left: 4,
                child: IconButton(
                  tooltip: l10n.sitePhotoViewerClose,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.onImage),
                ),
              ),
              if (total > 1)
                Positioned(
                  top: 16,
                  left: 56,
                  right: 56,
                  child: IgnorePointer(
                    child: Text(
                      l10n.sitePhotoViewerIndex(_index + 1, total),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.onImage,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 8,
                right: 8,
                child: SitePhotoOverflowButton(
                  canDelete: item.canDelete,
                  canSetCover: item.canSetCover,
                  isCover: _coverId == item.id,
                  onSelected: _onMenu,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.sitePhotoUploadedBy(
                              (name == null || name.isEmpty)
                                  ? l10n.sitePhotoUploaderUnknown
                                  : name,
                            ),
                            style: const TextStyle(
                              color: AppColors.onImage,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (when != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              l10n.sitePhotoUploadedAt(
                                formatDateDmY(when),
                              ),
                              style: TextStyle(
                                color: AppColors.onImage.withValues(alpha: 0.85),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
