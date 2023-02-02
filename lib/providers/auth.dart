import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './../models/http_exception.dart';

class Auth with ChangeNotifier {
  // firebase token expires after 1 hr
  String? _token;
  DateTime? _expiryDate;
  String? _userId;

  // Auth({this.token, this.expiryDate, this.userId});

  // getter to check is authenticated
  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String? get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String? email, String? password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDKPhtoGiF8hYHslATTl6OsBpQoZh0HC9c');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        // even though statusCode is 200 means 'OK', error is not NULL, means
        // some error is present
        throw HttpException(responseData['error']['message']);
      }

      // set token & user id in memory
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      notifyListeners(); // to update UI, to trigger Consumer in main.dart
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signup(String? email, String? password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String? email, String? password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}
