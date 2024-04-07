import 'package:flutter/material.dart';
import 'package:flutter_crudapp/ui/map/view/set_googlemap.dart';
import 'package:flutter_crudapp/ui/todoadd/view/todoaddpage.dart';
import 'package:flutter_crudapp/ui/todo/view/todoapp.dart';

// pages
void toDoPage({required BuildContext context}) => Navigator.push(
    context, MaterialPageRoute(builder: (context) => const ToDoApp()));

void addPage({required BuildContext context}) => Navigator.push(
    context, MaterialPageRoute(builder: (context) => TodoAddPage()));

void mapSamplePage({required BuildContext context}) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return SetGoogleMap();
    }));
