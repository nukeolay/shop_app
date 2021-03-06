import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  const Badge({
    Key? key,
    required this.child,
    required this.value,
    this.bgColor,
    this.labelColor,
    this.top,
    this.bottom,
    this.left,
    this.right,
  }) : super(key: key);

  final Widget? child;
  final String value;
  final Color? bgColor;
  final Color? labelColor;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child ?? const SizedBox(),
        Positioned(
          right: right ?? 8,
          top: top ?? 8,
          child: Container(
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: bgColor ?? Colors.grey,
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: labelColor ?? Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }
}
