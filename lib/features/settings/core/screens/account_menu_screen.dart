import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/features/settings/core/widgets/admin_menu.dart';
import '../widgets/standart_menu.dart';
import '/notifiers/auth.dart';
import '../../../../core/presentation/widgets/custom_navigation_bar.dart';

class AccountMenuScreen extends StatelessWidget {
  const AccountMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Auth>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const Icon(Icons.account_circle),
                  ],
                ),
              ),
              if (user.isAdmin) ...AdminMenu.getMenu(context),
              ...StandartMenu.getMenu(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}
