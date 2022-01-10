import 'package:flutter/material.dart';
import 'package:shop_app/constants/languages.dart';

import '/models/category.dart';

class ManageCategoryItem extends StatelessWidget {
  final Category category;

  const ManageCategoryItem(this.category, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: InkWell(
        onLongPress: () {
          print('pressed');
        },
        borderRadius: BorderRadius.circular(10.0),
        child: Ink(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.grey.shade200,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: FadeInImage(
                  width: 60,
                  height: 80,
                  placeholder:
                      const AssetImage('assets/images/placeholder.jpg'),
                  image: NetworkImage(
                    category.imageUrl,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.category),
                    Text('en: ${category.titles[Languages.en]}'),
                    Text('ru: ${category.titles[Languages.ru]}'),
                    Text('коллекция: ${category.isCollection ? "да" : "нет"}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
