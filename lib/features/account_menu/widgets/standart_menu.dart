import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/orders_screen.dart';
import '/features/account_menu/widgets/account_menu_button.dart';

class StandartMenu {
  static void _goToOrdersScreen(context) {
    Navigator.of(context).pushNamed(OrdersScreen.routeName);
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
      AccountMenuButton(
        buttonIcon: Icons.manage_accounts_outlined,
        buttonText: 'Настройки аккаунта',
        color: Colors.grey.shade100,
        buttonAction: () {},
      ),
      AccountMenuButton(
        buttonIcon: Icons.add_business_outlined,
        buttonText: 'Адрес доставки',
        color: Colors.grey.shade100,
        buttonAction: () {},
      ),
      AccountMenuButton(
        buttonIcon: Icons.assignment_outlined,
        buttonText: 'Заказы',
        color: Colors.grey.shade100,
        buttonAction: () => _goToOrdersScreen(context),
      ),
      AccountMenuButton(
        buttonIcon: Icons.exit_to_app,
        buttonText: 'Выход',
        color: Colors.grey.shade100,
        buttonAction: () => _logout(context),
      )
    ];
  }
}
