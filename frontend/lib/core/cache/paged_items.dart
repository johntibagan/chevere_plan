/// Resultado paginado en memoria (ciclo 3).
class PagedItems<T> {
  const PagedItems({
    required this.items,
    required this.hasMore,
    this.loadingMore = false,
  });

  final List<T> items;
  final bool hasMore;
  final bool loadingMore;

  static const defaultPageSize = 20;

  PagedItems<T> copyWith({
    List<T>? items,
    bool? hasMore,
    bool? loadingMore,
  }) {
    return PagedItems<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}
