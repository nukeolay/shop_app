import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/core/presentation/routes/routes.dart';
import 'package:shop_app/notifiers/auth.dart';
import 'package:shop_app/notifiers/cart.dart';
import 'package:shop_app/notifiers/orders.dart';
import 'package:shop_app/notifiers/products.dart';
import 'menu_button.dart';

class StandartMenu {
  static void _goToOrdersScreen(context) {
    Navigator.of(context).pushNamed(Routes.orders);
  }

  static void _logout(context) async {
    Provider.of<Orders>(context, listen: false).deleteUserData();
    Provider.of<Products>(context, listen: false).deleteUserData();
    Provider.of<Cart>(context, listen: false).deleteUserData();
    await Provider.of<Auth>(context, listen: false).logout();
    Navigator.of(context).pushReplacementNamed('/');
  }

  static List<Widget> getMenu(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: MenuButton(
          buttonIcon: Icons.manage_accounts_outlined,
          buttonText: 'Настройки аккаунта',
          color: Colors.grey.shade100,
          buttonAction: () {},
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: MenuButton(
          buttonIcon: Icons.add_business_outlined,
          buttonText: 'Адрес доставки',
          color: Colors.grey.shade100,
          buttonAction: () {},
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: MenuButton(
          buttonIcon: Icons.assignment_outlined,
          buttonText: 'Заказы',
          color: Colors.grey.shade100,
          buttonAction: () => _goToOrdersScreen(context),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: MenuButton(
          buttonIcon: Icons.exit_to_app,
          buttonText: 'Выход',
          color: Colors.grey.shade100,
          buttonAction: () => _logout(context),
        ),
      )
    ];
  }
}
