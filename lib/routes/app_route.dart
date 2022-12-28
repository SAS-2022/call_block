import 'package:call_blocker/home.dart';
import 'package:call_blocker/screens/calling_page.dart';
import 'package:flutter/material.dart';

class AppRoute {
  static const homePage = '/home';
  static const callingPage = '/calling_page';

  static Route<Object>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homePage:
        return MaterialPageRoute(
            builder: (_) => HomePage(), settings: settings);
      case callingPage:
        return MaterialPageRoute(
            builder: (_) => CallingPage(), settings: settings);
      default:
        return null;
    }
  }
}
