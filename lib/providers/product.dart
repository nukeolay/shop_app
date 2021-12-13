import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final List<String> imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite(String? authToken, String? userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final Uri url = Uri.https(
      'shop-app-demo-udemy-default-rtdb.firebaseio.com',
      '/userFavorites/$userId/$id.json',
      {'auth': authToken},
    );
    try {
      await http.put(
        url,
        body: jsonEncode(
          isFavorite,
        ),
      );
    } catch (error) {
      isFavorite = oldStatus;
      notifyListeners();
      throw HttpException("Change Favorute Status Failed!");
    }
  }
}
