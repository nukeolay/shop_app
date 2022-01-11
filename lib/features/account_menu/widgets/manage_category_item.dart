import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/core/presentation/routes/routes.dart';

import '/notifiers/categories.dart';
import '/features/account_menu/widgets/confirm_alert_dialog.dart';
import '/core/constants/languages.dart';

class ManageCategoryItem extends StatelessWidget {
  final String id;
  final String category;
  final List<String> titles;
  final bool isCollection;
  final String imageUrl;

  const ManageCategoryItem({
    required this.id,
    required this.category,
    required this.titles,
    required this.isCollection,
    required this.imageUrl,
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
          await Provider.of<Categories>(context, listen: false)
              .deleteCategory(id);
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
        ),
        child: ListTile(
          isThreeLine: true,
          title: Text(category),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('en: ${titles[Languages.en]}'),
              Text('ru: ${titles[Languages.ru]}'),
            ],
          ),
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
                Routes.editCategory,
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
