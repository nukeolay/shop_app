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

  List<Category> get categories {
    return [..._categories];
  }

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
        _categories = loadedCategories;
        print(_categories);
        notifyListeners();
      } catch (error) {
        print(
            '!!!!!!! EXCEPTION CATCHED: fetchAndSetCategories: ${error.toString()}');
        rethrow;
      }
    }
  }
}
