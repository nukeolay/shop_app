import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/account_menu/screens/edit_category_screen.dart';
import '/models/category.dart';
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
              Navigator.of(context).pushNamed(EditCategoryScreen.routeName);
            },
          )
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: categories.allCategories.length,
            itemBuilder: (_, index) {
              Category category = categories.allCategories[index];
              return Column(
                children: [
                  ManageCategoryItem(
                    id: category.id,
                    category: category.category,
                    titles: category.titles,
                    isCollection: category.isCollection,
                    imageUrl: category.imageUrl,
                  ),
                ],
              );
            }),
      ),
    );
  }
}
