import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:http/http.dart' as http;

import '../constants/server_constants.dart';
import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _products = [];

  final String? authToken;
  final String? userId;
  late appwrite.Client _client;
  late appwrite.Database db;

  Products(this.authToken, this.userId, this._products) {
    _init();
  }

  _init() {
    _client = appwrite.Client();
    _client
        .setEndpoint(ServerConstants.endpoint)
        .setProject(ServerConstants.projectId);
    db = appwrite.Database(_client);
  }

  List<Product> get products {
    return [..._products];
  }

  void deleteUserData() {
    _products = [];
  }

  List<Product> get favoriteItems {
    return _products.where((product) => product.isFavorite).toList();
  }

  List<Product> categoryByNameItems(String categoryName) {
    return _products.where((product) => product.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    try {
      appwrite_models.DocumentList productsDocs = await db.listDocuments(
          collectionId: ServerConstants.productsCollectionId);
      if (productsDocs.documents.isEmpty) return;
      appwrite_models.DocumentList favoritesDocs = await db.listDocuments(
          collectionId: ServerConstants.favoritesCollectionId);
      final List<Product> loadedProducts = [];
      productsDocs.documents.map(
        (productData) {
          loadedProducts.add(
            Product(
              id: productData.$id,
              title: productData.data['title'] as String,
              description: productData.data['description'],
              price: double.parse(productData.data['price'].toString()),
              salePrice: double.parse(productData.data['salePrice'].toString()),
              imageUrl: (productData.data['imageUrls'] as List<dynamic>)
                  .map((imageUrl) => imageUrl.toString())
                  .toList(),
              category: (productData.data['categories'] as List<dynamic>)
                  .map((category) => category.toString())
                  .toList(),
              isFavorite: favoritesDocs.documents.isEmpty
                  ? false
                  : favoritesDocs.documents[0].data['favoriteProducts'] == null
                      ? false
                      : (favoritesDocs.documents[0].data['favoriteProducts']
                              as List<dynamic>)
                          .contains(productData.$id),
            ),
          );
        },
      ).toList();
      _products = loadedProducts;
      notifyListeners();
    } catch (error) {
      print('fetchAndSetProducts: ${error.toString()}');
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      appwrite_models.Document newDocument = await db.createDocument(
        collectionId: ServerConstants.productsCollectionId,
        data: {
          'title': product.title,
          'price': product.price,
          'salePrice': 0,
          'description': product.description,
          'imageUrls': product.imageUrl,
          'categories': ['first', 'second'],
        },
        read: ['role:member'],
      );
      final newProduct = Product(
        id: newDocument.$id,
        title: product.title,
        description: product.description,
        price: product.price,
        salePrice: product.salePrice,
        imageUrl: product.imageUrl,
        category: product.category,
      );
      _products.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    int productIndex = _products.indexWhere((product) => product.id == id);
    if (productIndex >= 0) {
      final Uri url = Uri.https(
        'shop-app-demo-udemy-default-rtdb.firebaseio.com',
        '/products/$id.json',
        {'auth': authToken},
      );
      http.patch(
        url,
        body: jsonEncode(
          {
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
            'isFavorite': newProduct.isFavorite,
          },
        ),
      );
      _products[productIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String? id) async {
    final Uri url = Uri.https(
      'shop-app-demo-udemy-default-rtdb.firebaseio.com',
      '/products/$id.json',
      {'auth': authToken},
    );
    final existingProductIndex =
        _products.indexWhere((product) => product.id == id);
    var existingProduct = _products[existingProductIndex];
    _products.removeAt(existingProductIndex);
    notifyListeners();
    try {
      await http.delete(url);
      existingProduct.dispose();
    } catch (error) {
      _products.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Product Deletion Failed!");
    }
  }

  Product findById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }
}
