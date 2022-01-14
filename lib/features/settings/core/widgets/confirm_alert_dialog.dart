import 'package:flutter/material.dart';

class ConfirmAlertDialog extends StatelessWidget {
  const ConfirmAlertDialog({
    required this.title,
    required this.description,
    required this.leftButtonText,
    required this.rightButtonText,
    Key? key,
  }) : super(key: key);

  final String title;
  final String description;
  final String leftButtonText;
  final String rightButtonText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text(title),
      content: Text(description),
      actions: <Widget>[
        TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.blueGrey),
          ),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(leftButtonText),
        ),
        TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(rightButtonText)),
      ],
    );
  }
}
