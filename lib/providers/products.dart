import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  final String? authToken;
  final String? userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    Map<String, dynamic>? filterQueryParameters = filterByUser
        ? {
            'auth': authToken,
            'orderBy': '"creatorId"',
            'equalTo': '"$userId"',
          }
        : {'auth': authToken};
    var url = Uri.https(
      'shop-app-demo-udemy-default-rtdb.firebaseio.com',
      '/products.json',
      filterQueryParameters,
    );
    try {
      final http.Response response = await http.get(url);
      final Map<String, dynamic>? extractedData = jsonDecode(response.body);
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return;
      }
      url = Uri.https(
        'shop-app-demo-udemy-default-rtdb.firebaseio.com',
        '/userFavorites/$userId.json',
        {'auth': authToken},
      );
      final favoriteResponse = await http.get(url);
      final favoriteData = jsonDecode(favoriteResponse.body);
      extractedData.forEach((productId, productData) {
        loadedProducts.add(
          Product(
            id: productId,
            title: productData['title'] as String,
            description: productData['description'],
            price: productData['price'],
            imageUrl: productData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[productId] ?? false,
          ),
        );
        _items = loadedProducts;
        notifyListeners();
      });
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final Uri url = Uri.https(
      'shop-app-demo-udemy-default-rtdb.firebaseio.com',
      '/products.json',
      {'auth': authToken},
    );
    try {
      final http.Response response = await http.post(
        url,
        body: jsonEncode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          },
        ),
      );
      final newProduct = Product(
        id: jsonDecode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    int productIndex = _items.indexWhere((product) => product.id == id);
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
      _items[productIndex] = newProduct;
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
        _items.indexWhere((product) => product.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    try {
      await http.delete(url);
      existingProduct.dispose();
    } catch (error) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Product Deletion Failed!");
    }
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }
}
