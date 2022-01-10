import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:appwrite/appwrite.dart' as appwrite;
import '../constants/server_constants.dart';
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

  List<Category> get allCategories {
    return [..._categories];
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
    return _categories.firstWhere((element) => element.id == id);
  }

  List<Category> getCategoriesByIds(List<String> idsList) {
    List<Category> result = [];
    for (var id in idsList) {
      result.add(getCategoryById(id));
    }
    return result;
  }

  // List<String> getCategoryNamesByIds({
  //   required int languageIndex,
  //   required List<String> idsList,
  // }) {
  //   List<String> names = [];
  //   for (var item in _categories) {
  //     names.add(item.titles[languageIndex]);
  //   }
  //   return names;
  // }

  Future<void> fetchAndSetCategories() async {
    print('---"Categories.fetchAndSetCategories" called');
    if (isLogged && _categories.isEmpty) {
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
}
