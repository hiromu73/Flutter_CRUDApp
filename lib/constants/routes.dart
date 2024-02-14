// flutter
import 'package:flutter/material.dart';
import 'package:flutter_crudapp/view/setgooglemap.dart';
import 'package:flutter_crudapp/view/todoaddpage.dart';
import 'package:flutter_crudapp/view/todoapp.dart';

// pages
void toDoPage({required BuildContext context}) => Navigator.push(
    context, MaterialPageRoute(builder: (context) => const ToDoApp()));

void addPage({required BuildContext context}) => Navigator.push(
    context, MaterialPageRoute(builder: (context) => const TodoAddPage()));

void mapSamplePage({required BuildContext context}) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return  MapSample();
    }));
