import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/features/auth/screens/auth_screen.dart';
import 'package:shop_app/features/home/screens/home_screen.dart';
import '../notifiers/auth.dart';
import '../core/presentation/notifiers/providers.dart';
import '../core/presentation/routes/routes.dart';
import 'core/presentation/routes/custom_route.dart';
import 'core/presentation/screens/splash_screen.dart';

void main() => runApp(const MyApp());
// void main() => runApp(const AppWriteEditData()); // делает текущего пользователя админом

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.grey),
    );
    return MultiProvider(
      providers: providers,
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Voda Jewel',
          theme: ThemeData(
            fontFamily: 'Montserrat',
            pageTransitionsTheme: PageTransitionsTheme(builders: {
              TargetPlatform.android: CustomPageTransitionBuilder(),
              TargetPlatform.iOS: CustomPageTransitionBuilder(),
            }),
            primarySwatch: Colors.blueGrey,
            appBarTheme: const AppBarTheme(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Color(0xFF455A50),
            ),
            colorScheme: ThemeData.light()
                .colorScheme
                .copyWith(secondary: Colors.blueGrey),
            progressIndicatorTheme:
                const ProgressIndicatorThemeData(color: Colors.blueGrey),
          ),
          home: auth.isLogged
              ? const HomeScreen()
              : FutureBuilder(
                  future: auth.tryAutologin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          onGenerateRoute: Routes.onGenerateRoute,
        ),
      ),
    );
  }
}
