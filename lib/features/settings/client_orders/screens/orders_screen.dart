import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/core/presentation/widgets/empty.dart';
import 'package:shop_app/notifiers/orders.dart';
import '../widgets/order_item.dart' as wgt;

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заказы'),
      ),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.error != null) {
              return Center(
                child: Text('Ошибка: ${snapshot.error}'),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, _) {
                  return orderData.orders.isEmpty
                      ? const EmptyWidget(
                          emptyIcon: Icons.assignment_outlined,
                          emptyText: "Заказов нет")
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: orderData.orders.length,
                          itemBuilder: (ctx, index) =>
                              wgt.OrderItem(orderData.orders[index]),
                        );
                },
              );
            }
          }
        },
      ),
    );
  }
}
