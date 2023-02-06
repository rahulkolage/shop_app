import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './../models/http_exception.dart';

import './product.dart';

// using mixing via 'with'
class ProductsProvider with ChangeNotifier {
  List<Product> _items = [];

  // List<Product> _items = [
  //   Product(
  //     id: 'p1',
  //     title: 'Red Shirt',
  //     description: 'A red shirt - it is pretty red!',
  //     price: 29.99,
  //     imageUrl:
  //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  //   ),
  //   Product(
  //     id: 'p2',
  //     title: 'Trousers',
  //     description: 'A nice pair of trousers.',
  //     price: 59.99,
  //     imageUrl:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
  //   ),
  //   Product(
  //     id: 'p3',
  //     title: 'Yellow Scarf',
  //     description: 'Warm and cozy - exactly what you need for the winter.',
  //     price: 19.99,
  //     imageUrl:
  //         'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
  //   ),
  //   Product(
  //     id: 'p4',
  //     title: 'A Pan',
  //     description: 'Prepare any meal you want.',
  //     price: 49.99,
  //     imageUrl:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
  //   ),
  // ];

  // this is for pop up menu in products overview page
  // var _showFavoritesOnly = false;

  final String? authToken;
  final String? userId;

  // constructor
  // used for getting token from auth.dart to products_provider via main.dart
  ProductsProvider(this.authToken, this.userId, this._items);

  // this filtering approach using _showFavoritesOnly is good for application wide filter
  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((item) => item.isFavorite).toList();
    // }

    // spread operator, returns copy of _items
    return [..._items];
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  // filterByUser, optional positional argument
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        'https://flutter-http-2f887-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return;
      }

      // get favorites
      final favUrl = Uri.parse(
          'https://flutter-http-2f887-default-rtdb.asia-southeast1.firebasedatabase.app/userFavorites/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(favUrl);
      final favoriteData = json.decode(favoriteResponse.body);

      extractedData.forEach((productId, productData) {
        loadedProducts.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          isFavorite:
              favoriteData == null ? false : favoriteData[productId] ?? false,
          imageUrl: productData['imageUrl'],
        ));
      });

      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://flutter-http-2f887-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          // 'isFavorite': product.isFavorite,  // no longer needed here , as we stored it in userFavorites
          'creatorId': userId,
        }),
      );
      final newProd = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProd);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  // Future<void> addProduct(Product product) {
  //   final url = Uri.https(
  //       'flutter-http-2f887-default-rtdb.asia-southeast1.firebasedatabase.app',
  //       '/products.json');
  //   return http
  //       .post(url,
  //           body: json.encode({
  //             'title': product.title,
  //             'description': product.description,
  //             'imageUrl': product.imageUrl,
  //             'price': product.price,
  //             'isFavorite': product.isFavorite,
  //           }))
  //       .then((response) {
  //     final newProd = Product(
  //         id: json.decode(response.body)['name'],
  //         title: product.title,
  //         description: product.description,
  //         price: product.price,
  //         imageUrl: product.imageUrl);
  //     _items.add(newProd);
  //     notifyListeners();
  //   }).catchError((error) {
  //     throw error;
  //   });
  // }

  Future<void> updateProduct(String? id, Product newProd) async {
    final _prodIndex = _items.indexWhere((prod) => prod.id == id);

    if (_prodIndex >= 0) {
      // final url = Uri.https(
      //     'flutter-http-2f887-default-rtdb.asia-southeast1.firebasedatabase.app',
      //     '/products/$id.json');
      final url = Uri.parse(
          'https://flutter-http-2f887-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken');

      await http.patch(url,
          body: json.encode({
            'title': newProd.title,
            'description': newProd.description,
            'imageUrl': newProd.imageUrl,
            'price': newProd.price,
          }));

      _items[_prodIndex] = newProd;
      notifyListeners();
    } else {
      print('Not found');
    }
  }

  Future<void> deleteProduct(String id) async {
    // final url = Uri.https(
    //     'flutter-http-2f887-default-rtdb.asia-southeast1.firebasedatabase.app',
    //     '/products/$id.json');
    final url = Uri.parse(
        'https://flutter-http-2f887-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken');

    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    Product? existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      // rollback
      _items.insert(existingProductIndex, existingProduct!);
      notifyListeners();

      // throw custom Exception
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }

  // void deleteProduct(String id) {
  //   final url = Uri.https(
  //       'flutter-http-2f887-default-rtdb.asia-southeast1.firebasedatabase.app',
  //       '/products/$id.json');

  //   final existingProductIndex =
  //       _items.indexWhere((product) => product.id == id);
  //   Product? existingProduct = _items[existingProductIndex];

  //   _items.removeAt(existingProductIndex);
  //   notifyListeners();

  //   http.delete(url).then((response) {
  //     if (response.statusCode >= 400) {
  //       // throw custom Exception
  //       throw HttpException('Could not delete product.');
  //     }
  //     existingProduct = null;
  //   }).catchError((_) {
  //     // rollback
  //     _items.insert(existingProductIndex, existingProduct!);
  //     notifyListeners();
  //   });
  //   // _items.removeWhere((product) => product.id == id);
  // }
}
