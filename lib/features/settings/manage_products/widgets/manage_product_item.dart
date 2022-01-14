import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/notifiers/products.dart';
import '/core/presentation/routes/routes.dart';
import '/features/settings/core/widgets/confirm_alert_dialog.dart';

class ManageProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final Color? bgColor;

  const ManageProductItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.bgColor,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    Key _key = UniqueKey();

    return Dismissible(
      key: _key,
      direction: DismissDirection.endToStart,
      onDismissed: (_) async {
        try {
          await Provider.of<Products>(context, listen: false).deleteProduct(id);
        } catch (error) {
          scaffold.showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) => const ConfirmAlertDialog(
            title: 'Подтвердите действие',
            description: 'Вы уверены, что хотите удалить эту позицию?',
            leftButtonText: 'ОТМЕНА',
            rightButtonText: 'УДАЛИТЬ',
          ),
        );
      },
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26.0),
        color: Colors.red,
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
          color: bgColor,
        ),
        child: ListTile(
          title: Text(title),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: FadeInImage(
              width: 60,
              height: 60,
              placeholder: const AssetImage('assets/images/placeholder.jpg'),
              image: NetworkImage(
                imageUrl,
              ),
              fit: BoxFit.cover,
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                Routes.editProduct,
                arguments: id,
              );
            },
            icon: const Icon(Icons.edit),
          ),
        ),
      ),
    );
  }
}
