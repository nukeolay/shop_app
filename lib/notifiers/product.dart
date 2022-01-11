import 'package:flutter/material.dart';

import 'package:appwrite/models.dart' as appwrite_models;
import 'package:appwrite/appwrite.dart' as appwrite;
import '../core//constants/server_constants.dart';
import '../models/http_exception.dart';

class Product with ChangeNotifier {
  //TODO поменять модель продукта, добавить поля вес, еще что-то
  final String id;
  final String title;
  final String description;
  final double price;
  final double salePrice;
  final List<String> imageUrls;
  final List<String> categoryIds;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.salePrice,
    required this.imageUrls,
    required this.categoryIds,
    this.isFavorite = false,
  });

  Future<void> toggleFavorite(String? userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    // TODO Индус обещал вынести клиента в общий блок, чтобы можно было получать его из разных частей программы
    // TODO сделать чтобы сразу исчезал с экрана
    try {
      appwrite.Client _client = appwrite.Client();
      _client
          .setEndpoint(ServerConstants.endpoint)
          .setProject(ServerConstants.projectId);
      appwrite.Database db = appwrite.Database(_client);
      appwrite_models.DocumentList favoritesDocs = await db.listDocuments(
          collectionId: ServerConstants.favoritesCollectionId);
      if (favoritesDocs.documents.isEmpty) {
        await db.createDocument(
          collectionId: ServerConstants.favoritesCollectionId,
          data: {
            'userId': userId,
            'favoriteProducts': [id],
          },
        );
      } else if (favoritesDocs.documents[0].data["favoriteProducts"] == null) {
        favoritesDocs.documents[0].data['favoriteProducts'] = [id];
        db.updateDocument(
          collectionId: ServerConstants.favoritesCollectionId,
          documentId: favoritesDocs.documents[0].$id,
          data: {
            'favoriteProducts': [id],
          },
        );
      } else {
        if (isFavorite) {
          favoritesDocs.documents[0].data['favoriteProducts'].add(id);
        } else {
          favoritesDocs.documents[0].data['favoriteProducts'].remove(id);
        }
        db.updateDocument(
          collectionId: ServerConstants.favoritesCollectionId,
          documentId: favoritesDocs.documents[0].$id,
          data: {
            'favoriteProducts':
                favoritesDocs.documents[0].data['favoriteProducts']
          },
        );
      }
    } catch (error) {
      isFavorite = oldStatus;
      notifyListeners();
      print(error);
      throw HttpException("Change Favorite Status Failed!");
    }
  }

  bool isOnSale() {
    return (price != salePrice) && (salePrice != 0);
  }

  double actualPrice() {
    return isOnSale() ? salePrice : price;
  }
}
