import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/orders.dart' as prv;

class OrderItem extends StatefulWidget {
  final prv.OrderItem order;
  const OrderItem(this.order, {Key? key}) : super(key: key);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
      height: _isExpanded ? widget.order.products.length * 40.0 + 100.0 : 95,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              onTap: () {
                setState(
                  () {
                    _isExpanded = !_isExpanded;
                  },
                );
              },
              title: Text('${widget.order.amount.toStringAsFixed(1)} ₽'),
              subtitle: Text(
                DateFormat('dd.MM.yyyy hh:mm').format(widget.order.dateTime),
              ),
              trailing:
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: _isExpanded ? widget.order.products.length * 40 : 0,
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ...widget.order.products
                      .map((product) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    product.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text('${product.quantity} x ${product.price} ₽',
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.grey)),
                              ],
                            ),
                          ))
                      .toList()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
