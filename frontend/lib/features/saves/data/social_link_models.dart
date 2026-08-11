class SiteSocialLink {
  const SiteSocialLink({
    required this.id,
    required this.siteId,
    required this.url,
    this.network,
    this.title,
    this.description,
    this.imageUrl,
    this.sortOrder = 0,
  });

  final String id;
  final String siteId;
  final String url;
  final String? network;
  final String? title;
  final String? description;
  final String? imageUrl;
  final int sortOrder;

  factory SiteSocialLink.fromJson(Map<String, dynamic> json) {
    return SiteSocialLink(
      id: json['id'] as String,
      siteId: json['site_id'] as String,
      url: json['url'] as String,
      network: json['network'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Borrador de enlace en el formulario (antes de persistir).
class SocialLinkDraft {
  SocialLinkDraft({
    required this.url,
    this.network,
    this.title,
    this.description,
    this.imageUrl,
    this.existingId,
  });

  String url;
  String? network;
  String? title;
  String? description;
  String? imageUrl;
  String? existingId;
}
