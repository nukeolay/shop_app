import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/core/presentation/routes/routes.dart';
import '/models/category.dart';
import '/features/account_menu/widgets/manage_category_item.dart';
import '/notifiers/categories.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({Key? key}) : super(key: key);

  Future<void> _refreshCategories(BuildContext context) async {
    await Provider.of<Categories>(context, listen: false)
        .fetchAndSetCategories(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const FittedBox(child: Text('Управление категориями')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.editCategory);
            },
          )
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: _refreshCategories(context),
          builder: (ctx, snapshot) =>
              snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => _refreshCategories(context),
                      child: Consumer<Categories>(
                        builder: (ctx, categoriesData, _) {
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: categoriesData.allCategories.length,
                            itemBuilder: (_, index) {
                              Category category =
                                  categoriesData.allCategories[index];
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
                            },
                          );
                        },
                      ),
                    ),
        ),
      ),
    );
  }
}
