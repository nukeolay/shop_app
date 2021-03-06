import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../notifiers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String? authToken;
  final String? userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  void deleteUserData() {
    _orders = [];
  }

  Future<void> fetchAndSetOrders() async {
    final Uri url = Uri.https(
      'shop-app-demo-udemy-default-rtdb.firebaseio.com',
      '/orders/$userId.json',
      {'auth': authToken},
    );
    try {
      final response = await http.get(url);
      final List<OrderItem> loadedOrders = [];

      final Map<String, dynamic>? extractedData = jsonDecode(response.body);
      if (extractedData == null) {
        // _orders = [];
        // notifyListeners();
        return;
      }
      extractedData.forEach(
        (orderId, orderData) {
          loadedOrders.add(
            OrderItem(
              id: orderId,
              amount: double.parse(orderData['amount'].toString()),
              dateTime: DateTime.parse(
                orderData['dateTime'],
              ),
              products: (orderData['products'] as List<dynamic>)
                  .map((item) => CartItem(
                        // id: item['id'],
                        price: double.parse(item['price'].toString()),
                        salePrice: double.parse(item['salePrice'].toString()),
                        quantity: item['quantity'],
                        title: item['title'],
                      ))
                  .toList(),
            ),
          );
          _orders = loadedOrders.reversed.toList();
          notifyListeners();
        },
      );
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final Uri url = Uri.https(
      'shop-app-demo-udemy-default-rtdb.firebaseio.com',
      '/orders/$userId.json',
      {'auth': authToken},
    );
    final timeStamp = DateTime.now();
    final response = await http.post(
      url,
      body: jsonEncode(
        {
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map((item) => {
                    // 'id': item.id,
                    'title': item.title,
                    'quantity': item.quantity,
                    'price': item.price,
                  })
              .toList(),
        },
      ),
    );
    _orders.insert(
        0,
        OrderItem(
          id: jsonDecode(response.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: timeStamp,
        ));
    notifyListeners();
  }
}
