class CategoryFields {
  static const String id = 'id';
  static const String category = 'category';
  static const String titles = 'categoryTitles';
  static const String isCollection = 'isCollection';
  static const String imageUrl = 'imageUrl';
}

class Category {
  String id;
  String category;
  List<String> titles;
  bool isCollection;
  String imageUrl;

  Category({
    required this.id,
    required this.category,
    required this.titles,
    required this.isCollection,
    required this.imageUrl,
  });

  @override
  String toString() {
    return 'id: $id, category: $category, titles: $titles, isCollection: $isCollection, imageUrl: $imageUrl';
  }
}
