import 'package:flutter/material.dart';

// Thsi is for single route ON FLY cration
class CustomRoute extends MaterialPageRoute {
  CustomRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(
          builder: builder,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // we don't need default method
    // return super
    //     .buildTransitions(context, animation, secondaryAnimation, child);

    if (settings.name == '/') {
      return child;
    }

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

// This is for all routes
class CustomPageTransitionBuilder extends PageTransitionsBuilder {
    @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // we don't need default method
    // return super
    //     .buildTransitions(context, animation, secondaryAnimation, child);

    if (route.settings.name == '/') {
      return child;
    }

    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}