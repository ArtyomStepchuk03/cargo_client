import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:manager_mobile_client/feature/auth_page/cubit/auth_cubit.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/feature/main_page/main_page.dart';
import 'package:manager_mobile_client/feature/main_page/main_screen.dart';

import 'feature/auth_page/auth_page.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DependencyHolder(
      child: MaterialApp.router(
        routerConfig: _router,
        title: 'CargoDeal',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ru', 'RU'), // Russian
        ],
        theme: ThemeData(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF178E28),
              secondary: Color(0xFF5c6bc0),
            ),
            primaryColor: Color(0xFF178E28),
            primaryColorDark: Color(0xFF005f00),
            primaryColorLight: Color(0xFF56bf56),
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle.light,
              backgroundColor: Color(0xFF12AA72),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
            tabBarTheme: TabBarTheme(
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white, width: 2.0),
                ),
              ),
            )),
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
        ),
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

final authCubit = AuthCubit();

final GoRouter _router = GoRouter(
  initialLocation: '/auth',
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => BlocProvider.value(
        value: authCubit,
        child: AuthPage(),
      ),
    ),
    GoRoute(
      path: '/reservations',
      builder: (context, state) => BlocProvider.value(
        value: authCubit,
        child: MainPage(
          MainScreen.reservations,
        ),
      ),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => BlocProvider.value(
        value: authCubit,
        child: MainPage(
          MainScreen.orders,
        ),
      ),
    ),
    GoRoute(
      path: '/customers',
      builder: (context, state) => BlocProvider.value(
        value: authCubit,
        child: MainPage(
          MainScreen.customers,
        ),
      ),
    ),
    GoRoute(
      path: '/suppliers',
      builder: (context, state) => BlocProvider.value(
        value: authCubit,
        child: MainPage(
          MainScreen.suppliers,
        ),
      ),
    ),
    GoRoute(
      path: '/transportUnits',
      builder: (context, state) => BlocProvider.value(
        value: authCubit,
        child: MainPage(
          MainScreen.transportUnits,
        ),
      ),
    ),
    GoRoute(
      path: '/messages',
      builder: (context, state) => BlocProvider.value(
        value: authCubit,
        child: MainPage(
          MainScreen.messages,
        ),
      ),
    ),
    GoRoute(
      path: '/myData',
      builder: (context, state) => BlocProvider.value(
        value: authCubit,
        child: MainPage(
          MainScreen.myData,
        ),
      ),
    ),
  ],
  redirect: (context, state) {
    if (state.path == '/') {
      return '/auth';
    }
    return null;
  },
);
