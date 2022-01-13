import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:http/http.dart' as http;
import 'package:shop_app/notifiers/cart.dart';

import '../core/constants/server_constants.dart';
import '../models/http_exception.dart';
import './product.dart';

class Products with ChangeNotifier {
  List<Product> _products = [];
  bool isLogged = false;

  late appwrite.Client _client;
  late appwrite.Database db;

  Products(this.isLogged) {
    _init();
  }

  _init() async {
    print('2 Products() init called');
    _client = appwrite.Client();
    _client
        .setEndpoint(ServerConstants.endpoint)
        .setProject(ServerConstants.projectId);
    db = appwrite.Database(_client);
    await fetchAndSetProducts();
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

  List<Product> productsByCategory(String category) {
    return _products
        .where((product) => product.categoryIds.contains(category))
        .toList();
  }

  Future<void> fetchAndSetProducts([bool needRefresh = false]) async {
    print('---"Products.fetchAndSetProducts" called');
    if (isLogged && (_products.isEmpty || needRefresh)) {
      print('---"Products.fetchAndSetProducts" called and fetching...');
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
                salePrice:
                    double.parse(productData.data['salePrice'].toString()),
                imageUrls: (productData.data['imageUrls'] as List<dynamic>)
                    .map((imageUrl) => imageUrl.toString())
                    .toList(),
                categoryIds: (productData.data['categories'] as List<dynamic>)
                    .map((category) => category.toString())
                    .toList(),
                isFavorite: favoritesDocs.documents.isEmpty
                    ? false
                    : favoritesDocs.documents[0].data['favoriteProducts'] ==
                            null
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
        print(
            '!!!!!!! EXCEPTION CATCHED: fetchAndSetProducts: ${error.toString()}');
        rethrow;
      }
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      appwrite_models.Document newDocument = await db.createDocument(
        collectionId: ServerConstants.productsCollectionId,
        data: {
          'title': product.title,
          'price': product.price,
          'salePrice': product.salePrice,
          'description': product.description,
          'imageUrls': product.imageUrls,
          'categories': product.categoryIds,
        },
        read: ['role:member'],
      );
      final newProduct = Product(
        id: newDocument.$id,
        title: product.title,
        description: product.description,
        price: product.price,
        salePrice: product.salePrice,
        imageUrls: product.imageUrls,
        categoryIds: product.categoryIds,
      );
      _products.add(newProduct);
      notifyListeners();
    } catch (error) {
      print('!!!!!!! EXCEPTION CATCHED: addProduct: ${error.toString()}');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      int productIndex = _products
          .indexWhere((existingProduct) => existingProduct.id == product.id);
      if (productIndex >= 0) {
        db.updateDocument(
          collectionId: ServerConstants.productsCollectionId,
          documentId: product.id,
          data: {
            ProductFields.title: product.title,
            ProductFields.price: product.price,
            ProductFields.salePrice: product.salePrice,
            ProductFields.description: product.description,
            ProductFields.imageUrls: product.imageUrls,
            ProductFields.categoryIds: product.categoryIds
          },
        );
        _products[productIndex] = product;
        notifyListeners();
      }
    } catch (error) {
      print('!!!!!!! EXCEPTION CATCHED: updateProduct: ${error.toString()}');
      throw HttpException("Product Update Failed!");
    }
  }

  Future<void> deleteProduct(String id) async {
    int localProductIndex =
        _products.indexWhere((existingProduct) => existingProduct.id == id);
    Product existingProduct = _products.removeAt(localProductIndex);
    try {
      await db.deleteDocument(
        collectionId: ServerConstants.productsCollectionId,
        documentId: id,
      );
      // удаляем продукт из всех корзин
      appwrite_models.DocumentList cartList = await db.listDocuments(
          collectionId: ServerConstants.cartsCollectionId);
      for (var cart in cartList.documents) {
        List<String> productsInCartIds =
            (cart.data[CartFields.productIds] as List<dynamic>)
                .map((element) => element.toString())
                .toList();
        List<int> productsInCartQuantities =
            (cart.data[CartFields.productQuantities] as List<dynamic>)
                .map((element) {
          String el = element.toString();
          return int.parse(el);
        }).toList();
        if (productsInCartIds.contains(id)) {
          int productToDeleteIndex = productsInCartIds.indexOf(id);
          productsInCartQuantities.removeAt(productToDeleteIndex);
          productsInCartIds.remove(id);
          await db.updateDocument(
            collectionId: ServerConstants.cartsCollectionId,
            documentId: cart.$id,
            data: {
              CartFields.productIds: productsInCartIds,
              CartFields.productQuantities: productsInCartQuantities
            },
          );
        }
      }
      // удаляем продукт из всех избранных
      appwrite_models.DocumentList favoriteList = await db.listDocuments(
          collectionId: ServerConstants.favoritesCollectionId);
      for (var favorites in favoriteList.documents) {
        List<String> favoriteProducts =
            (favorites.data[ProductFields.favoriteProducts] as List<dynamic>)
                .map((element) => element.toString())
                .toList();
        if (favoriteProducts.contains(id)) {
          favoriteProducts.remove(id);
          await db.updateDocument(
            collectionId: ServerConstants.favoritesCollectionId,
            documentId: favorites.$id,
            data: {
              ProductFields.favoriteProducts: favoriteProducts,
            },
          );
        }
      }
      notifyListeners();
    } catch (error) {
      _products.insert(localProductIndex, existingProduct);
      notifyListeners();
      print('!!!!!!! EXCEPTION CATCHED: deleteProduct: ${error.toString()}');
      throw HttpException("Product Deletion Failed!");
    }
  }

  Product getProductById(String id) {
    return _products.firstWhere((product) => product.id == id);
  }
}
