import 'package:flutter/material.dart';

import '../screens/category_screen.dart';
import '../models/category.dart';

class CategoryItem extends StatelessWidget {
  final dynamic item;
  const CategoryItem(this.item, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item is String) {
      return Padding(
        padding: const EdgeInsets.only(
          left: 0.0,
          right: 10.0,
          top: 15.0,
          bottom: 0.0,
        ),
        child: Container(
          alignment: Alignment.centerLeft,
          width: double.infinity,
          child: Text(
            item,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 28,
            ),
          ),
        ),
      );
    } else {
      item as Category;
      return LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            Navigator.of(context).pushNamed(
              CategoryScreen.routeName,
              arguments: item,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.0),
                child: SizedBox(
                  width: constraints.maxWidth / 2 - 10,
                  height: constraints.maxWidth / 1.8,
                  child: GridTile(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14.0),
                      child: FadeInImage(
                        placeholder:
                            const AssetImage('assets/images/placeholder.jpg'),
                        image: NetworkImage(
                          item.imageUrl,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    footer: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: const [
                            0.0,
                            1.0,
                          ],
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.0),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          right: 8.0,
                          top: 20.0,
                          bottom: 15.0,
                        ),
                        child: Text(
                          item.titles[
                              0], // TODO вместо 0 передавать переменную, которая зависит от языка
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
