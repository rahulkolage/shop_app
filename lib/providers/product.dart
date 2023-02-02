import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './../models/http_exception.dart';

class Product with ChangeNotifier {
  final String? id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;

    final url = Uri.parse(
        'https://flutter-http-2f887-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$token');

    isFavorite = !isFavorite;
    notifyListeners();

    try {
      // make http call
      // final response = await http.patch(
      //   url,
      //   body: json.encode({
      //     'isFavorite': isFavorite,
      //   }),
      // );
      final response = await http.put(
        url,
        body: json.encode(isFavorite),
      );
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
