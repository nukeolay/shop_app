import 'package:flutter/material.dart';

import '/core/presentation/routes/routes.dart';
import '/features/settings/core/widgets/menu_button.dart';

class AdminMenu {
  static void _goToManageProductsScreen(context) {
    Navigator.of(context).pushNamed(Routes.manageProducts);
  }

  static void _goToManageCategoriesScreen(context) {
    Navigator.of(context).pushNamed(Routes.manageCategories);
  }

  static List<Widget> getMenu(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: MenuButton(
          buttonIcon: Icons.edit_rounded,
          buttonText: 'Управление товарами',
          color: Colors.blueGrey.shade100,
          buttonAction: () => _goToManageProductsScreen(context),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: MenuButton(
          buttonIcon: Icons.category_rounded,
          buttonText: 'Управление категориями',
          color: Colors.blueGrey.shade100,
          buttonAction: () => _goToManageCategoriesScreen(context),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: MenuButton(
          buttonIcon: Icons.account_balance_wallet_rounded,
          buttonText: 'Управление заказами',
          color: Colors.blueGrey.shade100,
          buttonAction: () {},
        ),
      ),
    ];
  }
}
