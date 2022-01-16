import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:shop_app/notifiers/product.dart';
import '../core/constants/server_constants.dart';
import '../models/http_exception.dart';
import '../models/category.dart';

class Categories with ChangeNotifier {
  List<Category> _categories = [];
  bool isLogged = false;

  late appwrite.Client _client;
  late appwrite.Database db;

  Categories(this.isLogged) {
    _init();
  }

  _init() async {
    print('4 Categories() init called');
    _client = appwrite.Client();
    _client
        .setEndpoint(ServerConstants.endpoint)
        .setProject(ServerConstants.projectId);
    db = appwrite.Database(_client);
    await fetchAndSetCategories();
  }

  List<Category> get fullList {
    return [...categories, ...collections];
  }

  List<Category> get fullListExceptWildcard {
    List<Category> result = [...fullList];
    result.removeWhere((element) => element.category == '*');
    return result;
  }

  List<Category> get categories {
    List<Category> categoriesCopy = [..._categories];
    categoriesCopy.removeWhere((category) => category.isCollection);
    return [...categoriesCopy];
  }

  List<Category> get collections {
    List<Category> categoriesCopy = [..._categories];
    categoriesCopy.removeWhere((category) => !category.isCollection);
    return [...categoriesCopy];
  }

  Category getCategoryById(String id) {
    return _categories.firstWhere(
      (element) => element.id == id,
    );
  }

  List<Category> getCategoriesByIds(List<String> idsList) {
    List<Category> result = [];
    for (var id in idsList) {
      result.add(getCategoryById(id));
    }
    return result;
  }

  Future<void> fetchAndSetCategories([bool needRefresh = false]) async {
    print('---"Categories.fetchAndSetCategories" called');
    if (isLogged && (_categories.isEmpty || needRefresh)) {
      print('---"Categories.fetchAndSetCategories" called and fetching...');
      try {
        appwrite_models.DocumentList categoriesDocs = await db.listDocuments(
            collectionId: ServerConstants.categoriesCollectionId);
        if (categoriesDocs.documents.isEmpty) return;
        final List<Category> loadedCategories = [];
        categoriesDocs.documents.map(
          (categoryData) {
            loadedCategories.add(
              Category(
                id: categoryData.$id,
                category: categoryData.data[CategoryFields.category] as String,
                titles:
                    (categoryData.data[CategoryFields.titles] as List<dynamic>)
                        .map((element) => element as String)
                        .toList(),
                isCollection:
                    categoryData.data[CategoryFields.isCollection] as bool,
                imageUrl: categoryData.data[CategoryFields.imageUrl] as String,
              ),
            );
          },
        ).toList();
        loadedCategories.sort(
          (a, b) => a.category.length.compareTo(b.category.length),
        );
        _categories = loadedCategories;
        notifyListeners();
      } catch (error) {
        print(
            '!!!!!!! EXCEPTION CATCHED: fetchAndSetCategories: ${error.toString()}');
        rethrow;
      }
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      int categoryIndex = _categories
          .indexWhere((existingCategory) => existingCategory.id == category.id);
      if (categoryIndex >= 0) {
        db.updateDocument(
          collectionId: ServerConstants.categoriesCollectionId,
          documentId: category.id,
          data: {
            CategoryFields.category: category.category,
            CategoryFields.titles: category.titles,
            CategoryFields.isCollection: category.isCollection,
            CategoryFields.imageUrl: category.imageUrl,
          },
        );
        _categories[categoryIndex] = category;
        notifyListeners();
      }
    } catch (error) {
      print('!!!!!!! EXCEPTION CATCHED: updateCategory: ${error.toString()}');
      throw HttpException("Category Update Failed!");
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      appwrite_models.Document newDocument = await db.createDocument(
        collectionId: ServerConstants.categoriesCollectionId,
        data: {
          CategoryFields.category: category.category,
          CategoryFields.titles: category.titles,
          CategoryFields.isCollection: category.isCollection,
          CategoryFields.imageUrl: category.imageUrl,
        },
        read: ['role:member'],
      );
      final newCategory = Category(
        id: newDocument.$id,
        category: category.category,
        titles: category.titles,
        isCollection: category.isCollection,
        imageUrl: category.imageUrl,
      );
      _categories.add(newCategory);
      notifyListeners();
    } catch (error) {
      print('!!!!!!! EXCEPTION CATCHED: addCategory: ${error.toString()}');
      throw HttpException("Category Add Failed!");
    }
  }

  Future<void> deleteCategory(String id) async {
    int existingCategoryIndex =
        _categories.indexWhere((existingCategory) => existingCategory.id == id);
    Category existingCategory = _categories.removeAt(existingCategoryIndex);
    notifyListeners();
    try {
      await db.deleteDocument(
        collectionId: ServerConstants.categoriesCollectionId,
        documentId: id,
      );
      // удаляем у всех продуктов ссылку на эту категорию
      appwrite_models.DocumentList productsList = await db.listDocuments(
          collectionId: ServerConstants.productsCollectionId);
      for (var product in productsList.documents) {
        List<String> productIds =
            (product.data[ProductFields.categoryIds] == null
                    ? []
                    : product.data[ProductFields.categoryIds] as List<dynamic>)
                .map((element) => element.toString())
                .toList();
        if (productIds.contains(id)) {
          productIds.remove(id);
          await db.updateDocument(
            collectionId: ServerConstants.productsCollectionId,
            documentId: product.$id,
            data: {
              ProductFields.categoryIds: productIds,
            },
          );
        }
      }
    } catch (error) {
      _categories.insert(existingCategoryIndex, existingCategory);
      notifyListeners();
      print('!!!!!!! EXCEPTION CATCHED: deleteCategory: ${error.toString()}');
      throw HttpException("Category Deletion Failed!");
    }
  }
}
