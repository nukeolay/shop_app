import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/wishlist_screen.dart';
import '../providers/auth.dart';
import '../screens/user_products_screen.dart';
import '../screens/orders_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            centerTitle: true,
            title: const Text(
              'Voda Jewel',
              textAlign: TextAlign.center,
            ),
            automaticallyImplyLeading: false,
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('Каталог'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.favorite_outlined),
            title: const Text('Список желаний'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(WishlistScreen.routeName);
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Заказы'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(OrdersScreen.routeName);
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Управление товарами'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductsScreen.routeName);
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Выйти'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
