import 'package:flutter/material.dart';
import 'package:shop_app/core/presentation/routes/routes.dart';

import '/features/account_menu/screens/manage_categories_screen.dart';
import '/features/account_menu/widgets/account_menu_button.dart';
import '../screens/manage_products_screen.dart';

class AdminMenu {
  static void _goToManageProductsScreen(context) {
    Navigator.of(context).pushNamed(Routes.manageProducts);
  }

  static void _goToManageCategoriesScreen(context) {
    Navigator.of(context).pushNamed(Routes.manageCategories);
  }

  static List<Widget> getMenu(BuildContext context) {
    return [
      AccountMenuButton(
        buttonIcon: Icons.edit_rounded,
        buttonText: 'Управление товарами',
        color: Colors.blueGrey.shade100,
        buttonAction: () => _goToManageProductsScreen(context),
      ),
      AccountMenuButton(
        buttonIcon: Icons.category_rounded,
        buttonText: 'Управление категориями',
        color: Colors.blueGrey.shade100,
        buttonAction: () => _goToManageCategoriesScreen(context),
      ),
      AccountMenuButton(
        buttonIcon: Icons.account_balance_wallet_rounded,
        buttonText: 'Управление заказами',
        color: Colors.blueGrey.shade100,
        buttonAction: () {},
      ),
    ];
  }
}
