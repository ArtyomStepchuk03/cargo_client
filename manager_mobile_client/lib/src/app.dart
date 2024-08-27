import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'ui/dependency/dependency_holder.dart';
import 'ui/authorization/authorization_widget.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DependencyHolder(
      child: MaterialApp(
        title: 'CargoDeal',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('ru')],
        theme: _buildTheme(context),
        home: AuthorizationWidget(),
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
