import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart' show NavigatorObserver;
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:gratitude_diary/features/jourmal/presentation/pages/home_screen.dart';
import 'package:gratitude_diary/features/jourmal/presentation/pages/login_screen.dart';
import 'package:gratitude_diary/features/jourmal/presentation/pages/revisit_gratitude_screen.dart';
import 'package:gratitude_diary/services/isar/isar_db.dart';

List<GoRoute> routes = [
  GoRoute(
    path: AppRoutes.login,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: AppRoutes.home,
    builder: (context, state) => HomePage(),
  ),
  GoRoute(
    path: AppRoutes.revisit,
    builder: (context, state) => RevisitGratitudePage(),
  ),
];

List<NavigatorObserver> observers = [BotToastNavigatorObserver()];

final router = GoRouter(
  observers: observers,
  initialLocation: AppRoutes.login,
  routes: routes,
  redirect: (context, state) async {
    if (state.fullPath == null ||
        state.fullPath == AppRoutes.login ||
        state.fullPath == AppRoutes.home) {
      final IsarDbService isarDbService = GetIt.I.get<IsarDbService>();
      final bool isUserLoggedIn = await isarDbService.isUserLoggedIn();
      return isUserLoggedIn ? AppRoutes.home : AppRoutes.login;
    }
    return state.fullPath;
  },
);

class AppRoutes {
  static const login = '/';
  static const home = '/home';
  static const revisit = '/revisit';
}
