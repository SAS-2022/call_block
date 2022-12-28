import 'package:flutter/material.dart';

class NavigationService {
  //Global navigation key for whole application
  GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();
  //Get app context
  BuildContext? get appContext => navigationKey.currentContext;

  //App route observer
  RouteObserver<Route<dynamic>> routeObserver = RouteObserver<Route<dynamic>>();

  static final NavigationService _instance = NavigationService._private();
  factory NavigationService() {
    return _instance;
  }
  NavigationService._private();

  static NavigationService get instance => _instance;

  //pushing a new page into the navigation stack
  Future<T?> pushNamed<T extends Object>(String routeName,
      {Object? args}) async {
    print('Navigation Key: $navigationKey');
    print('Navigation Key State: ${navigationKey.currentState}}');
    return navigationKey.currentState?.pushNamed<T>(routeName, arguments: args);
  }

  //navigate to page if not already on it
  Future<T?> pushNamedIfNotCurrent<T extends Object>(String routeName,
      {Object? args}) async {
    if (!isCurrent(routeName)) {
      return pushNamed(routeName, args: args);
    }
    return null;
  }

  //check if we are currently on the page that needs to be pushed
  bool isCurrent(String routeName) {
    bool isCurrent = false;
    navigationKey.currentState!.popUntil((route) {
      if (route.settings.name == routeName) {
        isCurrent = true;
      }
      return true;
    });
    return isCurrent;
  }

  //push a new page to the current stack
  Future<T?> push<T extends Object>(Route<T> route) async {
    return navigationKey.currentState?.push<T>(route);
  }

  //Replace the current route of the navigator by pushing the given route
  //and disposing thee previous one
  Future<T?> pushReplacementNamed<T extends Object, TO extends Object>(
      String routeName,
      {Object? args}) async {
    return navigationKey.currentState
        ?.pushReplacementNamed<T, TO>(routeName, arguments: args);
  }

  //Push route to a given name and remove routes until a named one
  Future<T?> pusNamedAndRemoveUntil<T extends Object>(
    String routeName, {
    Object? args,
    bool Function(Route<dynamic>)? predicate,
  }) async {
    return navigationKey.currentState?.pushNamedAndRemoveUntil(
        routeName, predicate ?? (_) => false,
        arguments: args);
  }

  //push to a give route and remove all previous until predicate return true
  Future<T?> pushAndRemoveUntil<T extends Object>(
    Route<T> route, {
    bool Function(Route<dynamic>)? predicate,
  }) async {
    return navigationKey.currentState
        ?.pushAndRemoveUntil<T>(route, predicate ?? (_) => false);
  }

  //returns a pop request to close the route
  Future<bool> maybePop<T extends Object>([Object? args]) async {
    return navigationKey.currentState!.maybePop<T>(args as T);
  }

  //if the navigator can be popped
  bool canPop() => navigationKey.currentState!.canPop();

  //Pop the most route of the navigator
  void goBack<T extends Object>({T? resutl}) async {
    navigationKey.currentState?.pop<T>(resutl);
  }

  //Calls [pop] repeadtly until predicate returns true
  void popUntil(String route) {
    navigationKey.currentState!.popUntil(ModalRoute.withName(route));
  }
}
