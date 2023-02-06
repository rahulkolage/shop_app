import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import './../models/http_exception.dart';

class Auth with ChangeNotifier {
  // firebase token expires after 1 hr
  String? _token;
  DateTime? _expiryDate;
  String? _userId;

  // manage timer
  Timer? _authTimer;

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
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=');

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

      // call auto logout, this will start timer
      _autoLogout();
      // call auto logout complete
      notifyListeners(); // to update UI, to trigger Consumer in main.dart

      // store login data on device in shared preferences after login.
      // This will be used for Auto login
      final prefs = await SharedPreferences.getInstance();
      // create data map using json encode
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate?.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> signup(String? email, String? password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String? email, String? password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  // shared preferences return boolean
  // use this function in main.dart
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    // json.decode() requires non-nullable String argument, but prefs.getString('userData') is String?
    // to handle it either use prefs.getString('userData')! or pass empty map prefs.getString('userData') ?? '{}'
    // or store in local variable and check of null
    // https://github.com/flutter/flutter/issues/96035

    // also for Map<String, Object> there will an error for DateTime.parse(extractedUserData['expiryDate'])
    // extractedUserData['token']; so use dynamic
    final extractedUserData = json.decode(prefs.getString('userData') ?? '{}')
        as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      // token not valid
      return false;
    }

    // have valid token, set variables again.
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;

    // cancel ongoing timer if logout from Drawer clicked
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  // set timer which will expire when token expire and
  // then call logout()
  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
