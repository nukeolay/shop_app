import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    required this.emptyIcon,
    required this.emptyText,
    Key? key,
  }) : super(key: key);

  final IconData emptyIcon;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            emptyIcon,
            size: 80,
            color: Colors.blueGrey,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              emptyText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                color: Colors.grey,
              ),
            ),
          )
        ],
      ),
    );
  }
}
