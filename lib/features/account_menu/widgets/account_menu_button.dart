import 'package:flutter/material.dart';

class AccountMenuButton extends StatelessWidget {
  const AccountMenuButton(
      {required this.buttonIcon,
      required this.buttonText,
      required this.color,
      required this.buttonAction,
      Key? key})
      : super(key: key);

  final IconData buttonIcon;
  final String buttonText;
  final Color color;
  final void Function()? buttonAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: buttonAction,
        tileColor: color, //Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        leading: Icon(buttonIcon),
        title: Text(buttonText),
      ),
    );
  }
}
