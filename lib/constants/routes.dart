import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:memoplace/ui/add/view/editpage.dart';
import 'package:memoplace/ui/login/view_model/auth_provider.dart';
import 'package:memoplace/ui/map/view/set_googlemap.dart';
import 'package:memoplace/ui/add/view/addpage.dart';
import 'package:memoplace/ui/memo/view/memoapp.dart';
import '../ui/login/view/loginpage.dart';

final _key = GlobalKey<NavigatorState>();
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  // 遷移をアニメーションにする。pageBuilder
  CustomTransitionPage<void> buildPageWithAnimation(Widget page) {
    return CustomTransitionPage<void>(
      child: page,
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

  return GoRouter(
    navigatorKey: _key,
    debugLogDiagnostics: true,
    initialLocation: LoginPage.routeLocation,
    routes: [
      GoRoute(
          path: LoginPage.routeLocation,
          name: LoginPage.routeName,
          pageBuilder: (context, state) =>
              MaterialPage(key: state.pageKey, child: const LoginPage())),
      GoRoute(
          path: MemoApp.routeLocation,
          name: MemoApp.routeName,
          pageBuilder: (context, state) =>
              MaterialPage(key: state.pageKey, child: const MemoApp())),
      GoRoute(
          path: AddPage.routeLocation,
          name: AddPage.routeName,
          pageBuilder: (context, state) =>
              buildPageWithAnimation(const AddPage())),
      GoRoute(
        path: EditPage.routeLocation,
        name: EditPage.routeName,
        builder: (context, state) {
          
          final DocumentSnapshot document = state.extra as DocumentSnapshot;
          return EditPage(document: document);
        },
      ),
      GoRoute(
          name: 'licensepage',
          path: '/licensepage',
          pageBuilder: (context, state) =>
              buildPageWithAnimation(const LicensePage(
                applicationName: 'MemoPlace',
                applicationVersion: '1.0.2',
                applicationLegalese: 'All rights reserved',
              ))),
      GoRoute(
          path: SetGoogleMap.routeLocation,
          name: SetGoogleMap.routeName,
          pageBuilder: (context, state) =>
              buildPageWithAnimation(SetGoogleMap())),
    ],
    // 遷移ページがないなどのエラーが発生した時に、このページに行く
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Text(state.error.toString()),
        ),
      ),
    ),
    redirect: (context, state) async {
      if (authState.isLoading || authState.hasError) return null;
      final isAuth = authState.valueOrNull != null;
      final isLogin = state.fullPath == LoginPage.routeLocation;
      final isLogingIn = state.fullPath == MemoApp.routeLocation;

      if (isLogin) {
        return isAuth ? MemoApp.routeLocation : LoginPage.routeLocation;
      }

      if (isLogingIn) {
        return isAuth ? MemoApp.routeLocation : LoginPage.routeLocation;
      }
      return null;
    },
  );
});
