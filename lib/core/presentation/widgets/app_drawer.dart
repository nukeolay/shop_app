import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/core/presentation/routes/routes.dart';
import '../../../notifiers/auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            centerTitle: true,
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Аккаунт'),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.payment),
            title: const Text('Заказы'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(Routes.orders);
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Управление товарами'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(Routes.manageProducts);
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Выйти'),
            onTap: () async {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/');
              await Provider.of<Auth>(context, listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}
