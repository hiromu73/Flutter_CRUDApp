import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CustomButton extends HookConsumerWidget {
  final double width;
  final double height;
  final Color color;
  final String text;
  final double elevation;
  final Function()? onPressd;
  final String? iconSVG;
  const CustomButton({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    required this.text,
    required this.onPressd,
    this.elevation = 6.0,
    this.iconSVG,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.sizeOf(context).width;
    final h = MediaQuery.sizeOf(context).height;
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
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (iconSVG != null)
                      Positioned(
                        left: 30,
                        top: 0,
                        bottom: 0,
                        child: Center(
                            child: SvgPicture.asset(
                          iconSVG!,
                          height: h * 0.03,
                        )),
                      ),
                  ],
                ),
                onPressed: () async {
                  onPressd!();
                }),
          ))),
    );
  }
}
