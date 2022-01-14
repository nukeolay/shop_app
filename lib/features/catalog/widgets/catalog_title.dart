import 'package:flutter/material.dart';

class CatalogTitle extends StatelessWidget {
  final String _title;

  const CatalogTitle(this._title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 0.0,
        right: 10.0,
        top: 15.0,
        bottom: 0.0,
      ),
      child: Container(
        alignment: Alignment.centerLeft,
        width: double.infinity,
        child: Text(
          _title,
          style: const TextStyle(
            color: Colors.blueGrey,
            fontSize: 28,
          ),
        ),
      ),
    );
  }
}
