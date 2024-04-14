import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memoplace/ui/map/view/set_googlemap.dart';
import 'package:memoplace/ui/add/view/addpage.dart';
import 'package:memoplace/ui/memo/view/memoapp.dart';

// pages
// void memoPage({required BuildContext context}) => Navigator.push(
//     context, MaterialPageRoute(builder: (context) => const MemoApp()));

// void addPage({required BuildContext context}) =>
//     Navigator.push(context, MaterialPageRoute(builder: (context) => AddPage()));

// void mapSamplePage({required BuildContext context}) =>
//     Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//       return SetGoogleMap();
//     }));

final router = GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: [
    GoRoute(
        name: 'home',
        path: '/',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const MemoApp())),
    GoRoute(
        name: 'addpage',
        path: '/addpage',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: AddPage())),
    GoRoute(
        name: 'setgooglemap',
        path: '/setgooglemap',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: SetGoogleMap())),
  ],
);
