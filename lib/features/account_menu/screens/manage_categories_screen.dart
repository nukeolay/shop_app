import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/account_menu/widgets/manage_category_item.dart';
import '/providers/categories.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({Key? key}) : super(key: key);
  static const String routeName = '/manage-categories-screen';

  @override
  Widget build(BuildContext context) {
    Categories categories = Provider.of<Categories>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const FittedBox(child: Text('Управление категориями')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            ...categories.allCategories
                .map((category) => ManageCategoryItem(category))
                .toList(),
          ],
        ),
      ),
    );
  }
}
