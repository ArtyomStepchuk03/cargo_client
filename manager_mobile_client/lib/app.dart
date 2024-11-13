import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:manager_mobile_client/feature/auth_page/auth_page.dart';
import 'package:manager_mobile_client/feature/auth_page/cubit/auth_cubit.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DependencyHolder(
      child: MaterialApp(
        title: 'CargoDeal',
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ru', 'RU'), // Russian
        ],
        theme: _buildTheme(context),
        home: BlocProvider(
          create: (context) => AuthCubit(),
          child: AuthPage(),
        ),
      ),
    );
  }

  ThemeData _buildTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        primary: Color(0xFF178E28),
        secondary: Color(0xFF5c6bc0),
      ),
      primaryColor: Color(0xFF178E28),
      primaryColorDark: Color(0xFF005f00),
      primaryColorLight: Color(0xFF56bf56),
      appBarTheme: theme.appBarTheme.copyWith(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        backgroundColor: Color(0xFF12AA72),
      ),
      tabBarTheme: theme.tabBarTheme.copyWith(
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white, width: 2.0),
          ),
        ),
      ),
    );
  }
}
