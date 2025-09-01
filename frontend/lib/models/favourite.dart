class FavoriteItem {
  final String title;
  final String imageUrl;

  FavoriteItem({required this.title, required this.imageUrl});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteItem &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;
}
