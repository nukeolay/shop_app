import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/notifiers/auth.dart';
enum authMode {
  signup,
  login,
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.5),
                  Colors.blueGrey.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 20.0),
                    padding: const EdgeInsets.all(20.0),
                    child: const Image(
                      image: AssetImage('assets/images/logo_named.png'),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: const AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  authMode _authMode = authMode.login;
  final Map<String?, String?> _authData = {
    'email': '',
    'password': '',
    'name': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _passwordConfirmFocusNode = FocusNode();

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _passwordConfirmFocusNode.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: const Text('Ошибка!'),
        content: Text(message),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text(
                'Ok',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == authMode.login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email']!,
          _authData['password']!,
        );
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signUp(
          email: _authData['email']!,
          password: _authData['password']!,
          name: _authData['name']!,
        );
      }
    } on HttpException catch (error) {
      var errorMessage = 'Ошибка входа';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'Данный адрес электронной почты уже зарегистрирован';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Указан некорректный адрес электронной почты';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'Пароль слишком простой';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Данный адрес электронной почты не зарегистрирован';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Неправильный пароль';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'Ошибка. Попробуйте позже';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == authMode.login) {
      setState(() {
        _authMode = authMode.signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = authMode.login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                    minHeight: 0,
                    maxHeight: _authMode == authMode.signup ? 80 : 0,
                  ),
                  curve: Curves.linear,
                  child: _authMode == authMode.signup
                      ? FadeTransition(
                          opacity: _opacityAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: TextFormField(
                              enabled: _authMode == authMode.signup,
                              decoration:
                                  const InputDecoration(labelText: 'Имя'),
                              onSaved: (value) {
                                _authData['name'] = value;
                              },
                              validator: _authMode == authMode.signup
                                  ? (value) {
                                      if (value == null || value == '') {
                                        return 'Не указано имя пользователя!';
                                      }
                                    }
                                  : null,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context)
                                    .requestFocus(_emailFocusNode);
                              },
                            ),
                          ),
                        )
                      : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Некорректный e-mail!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Пароль'),
                  obscureText: true,
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  validator: (value) {
                    if (value == null || value.length < 5) {
                      return 'Пароль слишком короткий!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                  onFieldSubmitted: (_) {
                    _authMode == authMode.signup
                        ? FocusScope.of(context)
                            .requestFocus(_passwordConfirmFocusNode)
                        : _submit();
                  },
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                    minHeight: 0,
                    maxHeight: _authMode == authMode.signup ? 80 : 0,
                  ),
                  curve: Curves.linear,
                  child: _authMode == authMode.signup
                      ? FadeTransition(
                          opacity: _opacityAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: TextFormField(
                                enabled: _authMode == authMode.signup,
                                focusNode: _passwordConfirmFocusNode,
                                decoration: const InputDecoration(
                                    labelText: 'Подтвердите пароль'),
                                obscureText: true,
                                validator: _authMode == authMode.signup
                                    ? (value) {
                                        if (value != _passwordController.text) {
                                          return 'Пароли не совпадают!';
                                        }
                                      }
                                    : null,
                                onFieldSubmitted: (_) {
                                  _submit();
                                }),
                          ),
                        )
                      : null,
                ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  RaisedButton(
                    child: Text(_authMode == authMode.login
                        ? 'ВОЙТИ'
                        : 'ЗАРЕГИСТРИРОВАТЬСЯ'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button!.color,
                  ),
                const SizedBox(
                  height: 5,
                ),
                FlatButton(
                  child: Text(_authMode == authMode.login
                      ? 'РЕГИСТРАЦИЯ'
                      : 'УЖЕ ЕСТЬ АККАУНТ'),
                  onPressed: _switchAuthMode,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
