import 'package:flutter/material.dart';

import '../../../core/constants/languages.dart';
import '../../../core/presentation/routes/routes.dart';
import '../../../models/category.dart';

class CategoryItem extends StatelessWidget {
  final Category _category;
  const CategoryItem(this._category, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // int productQuantity = 1; //_category.productQuantity;
    // if (productQuantity > 0) {
    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Navigator.of(context).pushNamed(
            Routes.category,
            arguments: _category,
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
                        _category.imageUrl,
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
                        _category.titles[Languages
                            .ru], // TODO вместо 0 передавать переменную, которая зависит от языка
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
  // }
  }
}
