import 'package:flutter/material.dart';

class ColoredDot extends StatelessWidget {
  const ColoredDot({
    Key? key,
    required this.color,
    this.paddingLeft = 0.0,
    this.paddingRight = 0.0,
    this.size = 8.0,
    this.addBorder = false,
  }) : super(key: key);

  final Color? color;
  final double paddingLeft;
  final double paddingRight;
  final double size;
  final bool addBorder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: paddingLeft,
        right: paddingRight,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          border: addBorder
              ? Border.all(
                  color: Colors.white,
                  width: 2.0,
                )
              : null,
          borderRadius: BorderRadius.circular(
            10.0,
          ),
        ),
      ),
    );
  }
}
