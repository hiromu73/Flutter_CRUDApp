import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memoplace/ui/map/view/set_googlemap.dart';
import 'package:memoplace/ui/add/view/addpage.dart';
import 'package:memoplace/ui/memo/view/memoapp.dart';
import '../ui/login/view/loginpage.dart';

final router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: [
    GoRoute(
        name: 'login',
        path: '/',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const LoginPage())),
    GoRoute(
        name: 'memolist',
        path: '/memolist',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const MemoApp())),
    GoRoute(
        name: 'addpage',
        path: '/addpage',
        pageBuilder: (context, state) =>
            _buildPageWithAnimation(const AddPage())),
    GoRoute(
        name: 'licensepage',
        path: '/licensepage',
        pageBuilder: (context, state) =>
            _buildPageWithAnimation(const LicensePage(
              applicationName: 'MemoPlace', // アプリの名前
              applicationVersion: '1.0.2', // バージョン
              applicationLegalese: 'All rights reserved', // 著作権表示
            ))),
    GoRoute(
        name: 'setgooglemap',
        path: '/setgooglemap',
        pageBuilder: (context, state) =>
            _buildPageWithAnimation(SetGoogleMap())),
  ],
);

// 遷移をアニメーションにする。pageBuilder
CustomTransitionPage<void> _buildPageWithAnimation(Widget page) {
  return CustomTransitionPage<void>(
    child: page,
    // transitionDuration: const Duration(milliseconds: 500),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(0, 10),
            end: Offset.zero,
          ).chain(
            CurveTween(curve: Curves.easeIn),
          ),
        ),
        child: child,
      );
    },
  );
}
