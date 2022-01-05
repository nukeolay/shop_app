import 'package:flutter/material.dart';

import 'package:appwrite/models.dart' as appwrite_models;
import 'package:appwrite/appwrite.dart' as appwrite;
import '../constants/server_constants.dart';
import '../providers/product.dart';

class CartItem {
  // final String id;
  final String title;
  final int quantity;
  final double price;
  final double salePrice;

  CartItem({
    // required this.id,
    required this.title,
    required this.quantity,
    required this.price,
    required this.salePrice,
  });
}

class Cart extends ChangeNotifier {
  final String? userId;
  final List<Product> products;

  Map<String, CartItem> _cartItems = {};

  late appwrite.Client _client;
  late appwrite.Database db;
  late appwrite_models.DocumentList cartDocs;
  String? cartDocId;

  Cart(this.userId, this.products, this._cartItems) {
    if (userId != null && products.isNotEmpty) _init();
  }

  _init() {
    // TODO вызывается каждый раз при открытии каталога
    _client = appwrite.Client();
    _client
        .setEndpoint(ServerConstants.endpoint)
        .setProject(ServerConstants.projectId);
    db = appwrite.Database(_client);
    print('init called!');
    fetchAndSetCart();
  }

  Map<String, CartItem> get cartItems {
    return {..._cartItems};
  }

  void deleteUserData() {
    _cartItems = {};
  }

  Future<void> fetchAndSetCart() async {
    try {
      cartDocs = await db.listDocuments(
          collectionId: ServerConstants.cartsCollectionId);
      if (cartDocs.documents.isEmpty) return;
      if (cartDocs.documents[0].data['userId'] != userId) return;
      cartDocId = cartDocs.documents[0].$id;
      final List<dynamic> loadedProductIds =
          cartDocs.documents[0].data['productIds'] ?? [];
      final List<dynamic> loadedProductQuantities =
          cartDocs.documents[0].data['productQuantities'] ?? [];
      for (String item in loadedProductIds) {
        int index = loadedProductIds.indexOf(item);
        Product loadedProduct =
            products.firstWhere((element) => element.id == item);

        _cartItems[item] = CartItem(
            // id: item,
            title: loadedProduct.title,
            quantity: loadedProductQuantities[index],
            price: loadedProduct.price,
            salePrice: loadedProduct.salePrice);
      }
      notifyListeners();
    } catch (error) {
      print('fetchAndSetCarts: ${error.toString()}');
      rethrow;
    }
  }

  int get itemCount {
    int count = 0;
    _cartItems.forEach(
      (key, cartItem) {
        count += cartItem.quantity;
      },
    );
    return count;
  }

  double get totalAmount {
    double total = 0.0;
    _cartItems.forEach(
      (key, cartItem) {
        double actualPrice =
            (cartItem.price != cartItem.salePrice) && (cartItem.salePrice != 0)
                ? cartItem.salePrice
                : cartItem.price;
        total += actualPrice * cartItem.quantity;
      },
    );
    return total;
  }

  void addItem({
    required String productId,
    required String title,
    required double price,
    required double salePrice,
  }) {
    if (_cartItems.containsKey(productId)) {
      _cartItems.update(
        productId,
        (existingItem) => CartItem(
          // id: existingItem.id,
          title: existingItem.title,
          quantity: existingItem.quantity + 1,
          price: existingItem.price,
          salePrice: existingItem.salePrice,
        ),
      );
    } else {
      _cartItems.putIfAbsent(
          productId,
          () => CartItem(
                // id: DateTime.now().toString(),
                title: title,
                quantity: 1,
                price: price,
                salePrice: salePrice,
              ));
    }
    notifyListeners();
    saveCart();
  }

  void removeItem(String productId) {
    _cartItems.remove(productId);
    notifyListeners();
    saveCart();
  }

  void removeSingleItem(String productId) {
    if (!_cartItems.containsKey(productId)) {
      return;
    }

    if (_cartItems[productId]!.quantity > 1) {
      _cartItems.update(
        productId,
        (existingCartItem) => CartItem(
            // id: existingCartItem.id,
            price: existingCartItem.price,
            salePrice: existingCartItem.salePrice,
            title: existingCartItem.title,
            quantity: existingCartItem.quantity - 1),
      );
    } else {
      _cartItems.remove(productId);
    }
    notifyListeners();
    saveCart();
  }

  void clear() {
    _cartItems = {};
    notifyListeners();
    saveCart();
  }

  bool isProductInCart(String productId) {
    return _cartItems.containsKey(productId);
  }

  int productQuantity(String productId) {
    try {
      return _cartItems[productId]!.quantity;
    } catch (e) {
      return 0;
    }
  }

  Future<void> saveCart() async {
    try {
      List<String> productIds = [];
      List<int> productQuantities = [];
      _cartItems.forEach((key, value) {
        productIds.add(key);
        productQuantities.add(value.quantity);
      });

      if (cartDocId == null) {
        cartDocId = (await db.createDocument(
          collectionId: ServerConstants.cartsCollectionId,
          data: {
            'userId': userId,
            'productIds': productIds,
            'productQuantities': productQuantities,
          },
        ))
            .$id;
      } else {
        await db.updateDocument(
          collectionId: ServerConstants.cartsCollectionId,
          documentId: cartDocId!,
          data: {
            'userId': userId,
            'productIds': productIds,
            'productQuantities': productQuantities,
          },
        );
      }
    } catch (error) {
      print('saveCart: ${error.toString()}');
      rethrow;
    }
  }
}
