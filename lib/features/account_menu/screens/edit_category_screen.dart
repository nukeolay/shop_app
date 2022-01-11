import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/constants/languages.dart';
import '/notifiers/categories.dart';
import '/models/category.dart';

class EditCategoryScreen extends StatefulWidget {
  const EditCategoryScreen({Key? key}) : super(key: key);
  static const String routeName = '/edit-category-screen';

  @override
  _EditCategoryScreenState createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _categoryFocusNode = FocusNode();
  final _titleEnFocusNode = FocusNode();
  final _titleRuFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();

  Category _editedCategory = Category(
    id: '',
    category: '',
    titles: ['', ''],
    isCollection: false,
    imageUrl: '',
  );

  Map<String, dynamic> _initValues = {
    CategoryFields.id: '',
    CategoryFields.category: '',
    CategoryFields.titles: ['', ''],
    CategoryFields.isCollection: false,
    // CategoryFields.imageUrl: '',
  };

  bool _isInit = true;
  bool _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final String? categoryId =
          ModalRoute.of(context)!.settings.arguments as String?;
      if (categoryId != null) {
        _editedCategory = Provider.of<Categories>(context, listen: false)
            .getCategoryById(categoryId);
        _initValues = {
          CategoryFields.id: _editedCategory.id,
          CategoryFields.category: _editedCategory.category,
          CategoryFields.titles: _editedCategory.titles,
          CategoryFields.isCollection: _editedCategory.isCollection,
          // CategoryFields.imageUrl: _editedCategory.imageUrl,
        };
        _imageUrlController.text = _editedCategory.imageUrl;
        _isInit = false;
      }
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _categoryFocusNode.dispose();
    _titleEnFocusNode.dispose();
    _titleRuFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    String value = _imageUrlController.text;
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!value.startsWith('http') && !value.startsWith('https')) ||
          (!value.endsWith('.png') &&
              !value.endsWith('.jpg') &&
              !value.endsWith('.jpeg') &&
              !value.endsWith('.gif'))) {
        return;
      } else {
        setState(() {});
      }
    }
  }

  Future<void> _saveForm() async {
    final bool _isValid = _form.currentState!.validate();
    if (_isValid) {
      _form.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      if (_editedCategory.id != '') {
        await Provider.of<Categories>(context, listen: false)
            .updateCategory(_editedCategory);
      } else {
        try {
          await Provider.of<Categories>(context, listen: false)
              .addCategory(_editedCategory);
        } catch (error) {
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Ошибка!'),
              content: Text('Что-то пошло не так: ${error.toString}'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Ok'),
                ),
              ],
            ),
          );
        }
        // finally {
        //   setState(() {
        //     _isLoading = false;
        //   });
        //   Navigator.of(context).pop();
        // }
      }
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(child: Text('Редактирование категории')),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    TextFormField(
                      initialValue: _initValues[CategoryFields.category],
                      decoration: const InputDecoration(labelText: 'Категория'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_titleEnFocusNode);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Укажите категорию';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedCategory = Category(
                          id: _editedCategory.id,
                          category: value!,
                          titles: _editedCategory.titles,
                          isCollection: _editedCategory.isCollection,
                          imageUrl: _editedCategory.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues[CategoryFields.titles]
                          [Languages.en],
                      decoration: const InputDecoration(
                          labelText: 'Наименование категориия (en)'),
                      textInputAction: TextInputAction.next,
                      focusNode: _titleEnFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_titleRuFocusNode);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Укажите категориия (en)';
                        }
                      },
                      onSaved: (value) {
                        _editedCategory.titles[Languages.en] = value!;
                        _editedCategory = Category(
                          id: _editedCategory.id,
                          category: _editedCategory.category,
                          titles: _editedCategory.titles,
                          isCollection: _editedCategory.isCollection,
                          imageUrl: _editedCategory.imageUrl,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues[CategoryFields.titles]
                          [Languages.ru],
                      decoration: const InputDecoration(
                          labelText: 'Наименование категориия (ru)'),
                      textInputAction: TextInputAction.next,
                      focusNode: _titleRuFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_imageUrlFocusNode);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Укажите категориия (ru)';
                        }
                      },
                      onSaved: (value) {
                        _editedCategory.titles[Languages.ru] = value!;
                        _editedCategory = Category(
                          id: _editedCategory.id,
                          category: _editedCategory.category,
                          titles: _editedCategory.titles,
                          isCollection: _editedCategory.isCollection,
                          imageUrl: _editedCategory.imageUrl,
                        );
                      },
                    ),
                    SwitchListTile.adaptive(
                        contentPadding: const EdgeInsets.all(0.0),
                        title: const Text('Коллекция'),
                        subtitle: const Text('включить если это коллекция'),
                        value: _initValues[CategoryFields.isCollection],
                        onChanged: (value) {
                          setState(() {
                            _initValues[CategoryFields.isCollection] = value;
                            _editedCategory.isCollection = value;
                          });
                        }),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            top: 8,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          width: 100,
                          height: 100,
                          child: _imageUrlController.text.isEmpty
                              ? const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.red,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: FadeInImage(
                                    imageErrorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.red,
                                    ),
                                    placeholder: const AssetImage(
                                        'assets/images/placeholder.jpg'),
                                    image: NetworkImage(
                                      _imageUrlController.text,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Ссылка на изображение'),
                            maxLines: 3,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onChanged: (_) {
                              setState(() {});
                            },
                            // onEditingComplete: () {
                            //   setState(() {});
                            // },
                            onFieldSubmitted: (_) => _saveForm(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Введите ссылку';
                              }
                              if (!value.startsWith('http') &&
                                  !value.startsWith('https')) {
                                return 'Введите ссылку';
                              }
                              if (!value.endsWith('.png') &&
                                  !value.endsWith('.jpg') &&
                                  !value.endsWith('.jpeg') &&
                                  !value.endsWith('.gif')) {
                                return 'Введите ссылку на изображение';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _editedCategory = Category(
                                id: _editedCategory.id,
                                category: _editedCategory.category,
                                titles: _editedCategory.titles,
                                isCollection: _editedCategory.isCollection,
                                imageUrl: value!,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
