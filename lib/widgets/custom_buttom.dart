import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memoplace/ui/login/view/authentication.dart';
import 'package:memoplace/ui/login/view_model/anonymous_class.dart';
import 'package:memoplace/ui/login/view_model/loginuser.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class CustomButton extends HookConsumerWidget {
  final double width;
  final double height;
  final Color color;
  final String text;
  final double elevation;
  final Function()? onPressd;
  const CustomButton(
      {super.key,
      required this.width,
      required this.height,
      required this.color,
      required this.text,
      required this.onPressd,
      this.elevation = 6.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      child: Container(
          color: color,
          child: Center(
              child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.4),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(3, 3),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(-3, -3),
                ),
              ],
            ),
            child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  onPressd!();
                }),
          ))),
    );
  }
}
