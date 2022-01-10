import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';
import '../providers/products.dart';
import '../providers/orders.dart';
import '../screens/orders_screen.dart';
import '../screens/manage_products_screen.dart';
import '../widgets/custom_navigation_bar.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);
  static const String routeName = '/account-screen';

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  void _goToOrdersScreen() {
    Navigator.of(context).pushNamed(OrdersScreen.routeName);
  }

  void _goToManageProductsScreen() {
    Navigator.of(context).pushNamed(ManageProductsScreen.routeName);
  }

  void _logout() async {
    Provider.of<Orders>(context, listen: false).deleteUserData();
    Provider.of<Products>(context, listen: false).deleteUserData();
    Provider.of<Cart>(context, listen: false).deleteUserData();
    await Provider.of<Auth>(context, listen: false).logout();
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    final name = Provider.of<Auth>(context, listen: false).name;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name),
            const Icon(Icons.account_circle),
          ],
        ),
        actions: const [],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              AccountMenuButton(
                buttonIcon: Icons.assignment_outlined,
                buttonText: 'Мои заказы',
                buttonAction: _goToOrdersScreen,
              ),
              AccountMenuButton(
                buttonIcon: Icons.edit_outlined,
                buttonText: 'Управление товарами',
                buttonAction: _goToManageProductsScreen,
              ),
              AccountMenuButton(
                buttonIcon: Icons.exit_to_app,
                buttonText: 'Выход',
                buttonAction: _logout,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}

class AccountMenuButton extends StatelessWidget {
  const AccountMenuButton(
      {required this.buttonIcon,
      required this.buttonText,
      required this.buttonAction,
      Key? key})
      : super(key: key);

  final IconData buttonIcon;
  final String buttonText;
  final void Function()? buttonAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: buttonAction,
        tileColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        leading: Icon(buttonIcon),
        title: Text(buttonText),
      ),
    );
  }
}
