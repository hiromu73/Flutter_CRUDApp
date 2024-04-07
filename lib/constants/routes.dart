import 'package:flutter/material.dart';
import 'package:flutter_crudapp/ui/map/view/set_googlemap.dart';
import 'package:flutter_crudapp/ui/add/view/addpage.dart';
import 'package:flutter_crudapp/ui/memo/view/memoapp.dart';

// pages
void memoPage({required BuildContext context}) => Navigator.push(
    context, MaterialPageRoute(builder: (context) => const MemoApp()));

void addPage({required BuildContext context}) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddPage()));

void mapSamplePage({required BuildContext context}) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return SetGoogleMap();
    }));
