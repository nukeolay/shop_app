import 'package:flutter/material.dart';

class AddImageToProductScreen extends StatefulWidget {
  const AddImageToProductScreen({Key? key}) : super(key: key);

  @override
  _AddImageToProductScreenState createState() =>
      _AddImageToProductScreenState();
}

class _AddImageToProductScreenState extends State<AddImageToProductScreen> {
  bool _isInit = true;

  final _form = GlobalKey<FormState>();
  final List<String> _imageUrls = [];
  late Function _addImageUrls;
  final List<TextEditingController> _imageUrlControllers = [];
  final List<FocusNode> _imageUrlFocusNodes = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      List<Object> _modalRouteArguments =
          ModalRoute.of(context)!.settings.arguments as List<Object>;
      _imageUrls.addAll(_modalRouteArguments[0] as List<String>);
      _addImageUrls = _modalRouteArguments[1] as Function;
      _isInit = false;
    }
    if (_imageUrls.isNotEmpty) {
      for (var imageUrl in _imageUrls) {
        TextEditingController _imageUrlController =
            TextEditingController(text: imageUrl);
        _imageUrlControllers.add(_imageUrlController);
        FocusNode _imageFocusNode = FocusNode()
          ..addListener(() => _updateImageUrl(_imageUrlController));
        _imageUrlFocusNodes.add(_imageFocusNode);
      }
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    for (var _imageUrlController in _imageUrlControllers) {
      _imageUrlController.dispose();
    }
    for (var _imageUrlFocusNode in _imageUrlFocusNodes) {
      _imageUrlFocusNode.dispose();
    }
    super.dispose();
  }

  void _updateImageUrl(TextEditingController _imageUrlController) {
    String value = _imageUrlController.text;
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

  void _saveForm() {
    if (_imageUrls.isNotEmpty) {
      final bool _isValid = _form.currentState!.validate();
      if (_isValid) {
        _form.currentState!.save();
        _addImageUrls(_imageUrls);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Изображения'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save, color: Colors.green),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _imageUrls.add('');
                TextEditingController _imageUrlController =
                    TextEditingController();
                _imageUrlControllers.add(_imageUrlController);
                FocusNode _imageFocusNode = FocusNode()
                  ..addListener(() => _updateImageUrl(_imageUrlController));
                _imageUrlFocusNodes.add(_imageFocusNode);
              });
            },
            icon: const Icon(
              Icons.add,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
      body: _imageUrls.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Пожалуйста добавьте хотя бы одно изображение товара',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).errorColor,
                    fontSize: 26.0,
                  ),
                ),
                const SizedBox(height: 20),
                IconButton(
                  highlightColor: Colors.grey.shade200,
                  iconSize: 50.0,
                  onPressed: () {
                    setState(() {
                      _imageUrls.add('');
                      TextEditingController _imageUrlController =
                          TextEditingController();
                      _imageUrlControllers.add(_imageUrlController);
                      FocusNode _imageFocusNode = FocusNode()
                        ..addListener(
                            () => _updateImageUrl(_imageUrlController));
                      _imageUrlFocusNodes.add(_imageFocusNode);
                    });
                  },
                  icon: const Icon(
                    Icons.add_photo_alternate_rounded,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            )
          : Form(
              key: _form,
              child: ReorderableListView.builder(
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final String _oldImageUrl = _imageUrls.removeAt(oldIndex);
                    _imageUrls.insert(newIndex, _oldImageUrl);
                    final TextEditingController _oldUrlController =
                        _imageUrlControllers.removeAt(oldIndex);
                    _imageUrlControllers.insert(newIndex, _oldUrlController);
                  });
                },
                physics: const BouncingScrollPhysics(),
                itemCount: _imageUrls.length,
                itemBuilder: (context, index) => Dismissible(
                  key: ValueKey(_imageUrlControllers[index]),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    setState(() {
                      _imageUrlControllers.removeAt(index);
                      _imageUrlFocusNodes.removeAt(index);
                      _imageUrls.removeAt(index);
                    });
                  },
                  background: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 26.0),
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10.0),
                    leading: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      width: 50,
                      height: 50,
                      child: _imageUrlControllers[index].text.isEmpty
                          ? const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.red,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: FadeInImage(
                                imageErrorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.red,
                                ),
                                placeholder: const AssetImage(
                                    'assets/images/placeholder.jpg'),
                                image: NetworkImage(
                                  _imageUrlControllers[index].text,
                                ),
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                    ),
                    title: TextFormField(
                      decoration: const InputDecoration(
                          labelText: 'Ссылка на изображение'),
                      keyboardType: TextInputType.url,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      focusNode: _imageUrlFocusNodes[index],
                      controller: _imageUrlControllers[index],
                      onChanged: (_) {
                        setState(() {});
                      },
                      onFieldSubmitted: (_) {},
                      validator: (value) {
                        if (value!.isEmpty) {
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
                        _imageUrls[index] = value!;
                      },
                    ),
                    trailing: const Icon(Icons.drag_handle_rounded),
                  ),
                ),
              ),
            ),
    );
  }
}
