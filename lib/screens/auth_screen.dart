import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../providers/auth.dart';

import './../models/http_exception.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key? key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController? _controller;
  Animation<Size>? _heightAnimation;
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // _heightAnimation = Tween<Size>(
    //         begin: const Size(double.infinity, 260),
    //         end: const Size(double.infinity, 320))
    //     .animate(CurvedAnimation(
    //   parent: _controller!,
    //   curve: Curves.linear,
    // ));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.fastOutSlowIn),
    );

    // _heightAnimation!.addListener(() => setState(() {}));  // will use AnimatedBuilder instead at Container
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('An Error Occurred!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
          _authData['email'],
          _authData['password'],
        );
      }
    } on HttpException catch (error) {
      var errMsg = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errMsg = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errMsg = 'This is not a valid email address.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errMsg = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errMsg = 'Could not find user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errMsg = 'Invalid password.';
      }
      _showErrorDialog(errMsg);
    } catch (error) {
      const errMsg = 'Could not authenticate you. Please try again later.';
      _showErrorDialog(errMsg);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller!.forward(); //  .forward() starts animation
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller!
          .reverse(); // .reverse() shrinks container as we go back to login
    }
  }

  // Using AnimatedContainer
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
          height: _authMode == AuthMode.Signup ? 320 : 260,
          constraints: BoxConstraints(
              minHeight: _authMode == AuthMode.Signup ? 320 : 260),
          width: deviceSize.width * 0.75,
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'E-Mail'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Invalid email!';
                      }
                      return null;
                      // return null;
                    },
                    onSaved: (value) {
                      _authData['email'] = value!;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value!.isEmpty || value!.length < 5) {
                        return 'Password is too short!';
                      }
                    },
                    onSaved: (value) {
                      _authData['password'] = value!;
                    },
                  ),
                  // if (_authMode == AuthMode.Signup)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    constraints: BoxConstraints(
                      minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                      maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                    ),
                    child: FadeTransition(
                      opacity: _opacityAnimation!,
                      child: SlideTransition(
                        position: _slideAnimation!,
                        child: TextFormField(
                          enabled: _authMode == AuthMode.Signup,
                          decoration: const InputDecoration(
                              labelText: 'Confirm Password'),
                          obscureText: true,
                          validator: _authMode == AuthMode.Signup
                              ? (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match!';
                                  }
                                }
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            Theme.of(context).textTheme.button?.color,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                          _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),

                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(30),
                      // ),
                      // padding:
                      //     EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      // color: Theme.of(context).primaryColor,
                      // textColor: Theme.of(context).primaryTextTheme.button.color,
                    ),
                  TextButton(
                    onPressed: _switchAuthMode,
                    style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD',
                    ),

                    // padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                    // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    // textColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  // // Using AnimatedBuilder and controller
  // @override
  // Widget build(BuildContext context) {
  //   final deviceSize = MediaQuery.of(context).size;
  //   return Card(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(10.0),
  //       ),
  //       elevation: 8.0,
  //       child: AnimatedBuilder(
  //         animation: _heightAnimation!,
  //         builder: (ctx, ch) => Container(
  //             // height: _authMode == AuthMode.Signup ? 320 : 260,
  //             height: _heightAnimation!.value.height,
  //             constraints: BoxConstraints(
  //                 minHeight: _heightAnimation!
  //                     .value.height), //_authMode == AuthMode.Signup ? 320 : 260
  //             width: deviceSize.width * 0.75,
  //             padding: const EdgeInsets.all(16.0),
  //             child: ch),

  //         // child below is part which will not rebuild, is passed tp Container child in builder
  //         child: Form(
  //           key: _formKey,
  //           child: SingleChildScrollView(
  //             child: Column(
  //               children: <Widget>[
  //                 TextFormField(
  //                   decoration: const InputDecoration(labelText: 'E-Mail'),
  //                   keyboardType: TextInputType.emailAddress,
  //                   validator: (value) {
  //                     if (value!.isEmpty || !value.contains('@')) {
  //                       return 'Invalid email!';
  //                     }
  //                     return null;
  //                     // return null;
  //                   },
  //                   onSaved: (value) {
  //                     _authData['email'] = value!;
  //                   },
  //                 ),
  //                 TextFormField(
  //                   decoration: const InputDecoration(labelText: 'Password'),
  //                   obscureText: true,
  //                   controller: _passwordController,
  //                   validator: (value) {
  //                     if (value!.isEmpty || value!.length < 5) {
  //                       return 'Password is too short!';
  //                     }
  //                   },
  //                   onSaved: (value) {
  //                     _authData['password'] = value!;
  //                   },
  //                 ),
  //                 if (_authMode == AuthMode.Signup)
  //                   TextFormField(
  //                     enabled: _authMode == AuthMode.Signup,
  //                     decoration:
  //                         const InputDecoration(labelText: 'Confirm Password'),
  //                     obscureText: true,
  //                     validator: _authMode == AuthMode.Signup
  //                         ? (value) {
  //                             if (value != _passwordController.text) {
  //                               return 'Passwords do not match!';
  //                             }
  //                           }
  //                         : null,
  //                   ),
  //                 const SizedBox(height: 20),
  //                 if (_isLoading)
  //                   CircularProgressIndicator()
  //                 else
  //                   ElevatedButton(
  //                     onPressed: _submit,
  //                     style: ElevatedButton.styleFrom(
  //                       foregroundColor:
  //                           Theme.of(context).textTheme.button?.color,
  //                       padding: const EdgeInsets.symmetric(
  //                           horizontal: 30.0, vertical: 8.0),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(30),
  //                       ),
  //                     ),
  //                     child: Text(
  //                         _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),

  //                     // shape: RoundedRectangleBorder(
  //                     //   borderRadius: BorderRadius.circular(30),
  //                     // ),
  //                     // padding:
  //                     //     EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
  //                     // color: Theme.of(context).primaryColor,
  //                     // textColor: Theme.of(context).primaryTextTheme.button.color,
  //                   ),
  //                 TextButton(
  //                   onPressed: _switchAuthMode,
  //                   style: TextButton.styleFrom(
  //                       foregroundColor: Theme.of(context).primaryColor,
  //                       padding: const EdgeInsets.symmetric(
  //                           horizontal: 30.0, vertical: 4),
  //                       tapTargetSize: MaterialTapTargetSize.shrinkWrap),
  //                   child: Text(
  //                     '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD',
  //                   ),

  //                   // padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
  //                   // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //                   // textColor: Theme.of(context).primaryColor,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ));
  // }
}
