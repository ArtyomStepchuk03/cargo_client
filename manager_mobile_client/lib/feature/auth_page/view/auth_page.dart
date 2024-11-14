import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:manager_mobile_client/common/fullscreen_activity_widget.dart';
import 'package:manager_mobile_client/feature/auth_page/cubit/auth_cubit.dart';
import 'package:manager_mobile_client/feature/auth_page/widget/authorization_error_widget.dart';
import 'package:manager_mobile_client/feature/auth_page/widget/log_in_widget.dart';
import 'package:manager_mobile_client/feature/auth_page/widget/no_internet_widget.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/logic/external/push_notification_client.dart';
import 'package:manager_mobile_client/src/logic/external/reachability.dart';
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';
import 'package:manager_mobile_client/src/logic/user_manager/configuration_loader.dart';
import 'package:manager_mobile_client/src/logic/user_manager/installation_manager.dart';
import 'package:manager_mobile_client/src/logic/user_manager/user_manager.dart';
import 'package:manager_mobile_client/util/localization_util.dart';

class AuthPage extends StatefulWidget {
  @override
  State createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  _AuthPageState()
      : _connected = true,
        _sessionChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reachability == null) {
      final dependencyState = DependencyHolder.of(context);
      _reachability = dependencyState.network.reachability;
      _serverManager = dependencyState.network.serverManager;
      _installationManager = dependencyState.network.installationManager;
      _userManager = dependencyState.network.userManager;
      _configurationLoader = dependencyState.network.configurationLoader;
      _pushNotificationClient = dependencyState.network.pushNotificationClient;
      _checkStatus();
    }
  }

  @override
  void dispose() {
    _reachabilitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    return _AuthorizationScopeWidget(
      state: this,
      child: Scaffold(
        appBar: AppBar(title: Text(localizationUtil.titleAuth)),
        body: _buildContent(),
      ),
    );
  }

  Reachability _reachability;
  ServerManager _serverManager;
  InstallationManager _installationManager;
  UserManager _userManager;
  ConfigurationLoader _configurationLoader;
  PushNotificationClient _pushNotificationClient;

  bool _connected;

  bool _sessionChecked;
  StreamSubscription<bool> _reachabilitySubscription;

  Widget _buildContent() {
    return BlocConsumer<AuthCubit, AuthState>(listener: (context, state) {
      if (state is SuccessAuthState) {
        context.go("/reservations");
      }
    }, builder: (_, state) {
      if (state is LoadingAuthState) {
        return FullscreenActivityWidget();
      }
      if (state is SuccessAuthState) {
        return FullscreenActivityWidget();
      }
      if (!_connected) {
        return NoInternetWidget();
      }
      if (state is ErrorAuthState) {
        return AuthorizationErrorWidget(onRetry: _recheckSession);
      }
      return LogInWidget();
    });
  }

  void _checkStatus() async {
    _connected = await _reachability.checkStatus();

    if (_connected) {
      _checkSession();
    } else {
      context.read<AuthCubit>().setUnauthorized();
    }

    _reachabilitySubscription =
        _reachability.onStatusChanged.listen((bool connected) {
      if (connected && !_sessionChecked) {
        setState(() => _connected = true);
        _checkSession();
      } else {
        setState(() => _connected = connected);
      }
    });
  }

  void _recheckSession() {
    context.read<AuthCubit>().setLoading();
    _checkSession();
  }

  void _checkSession() async {
    _sessionChecked = true;
    try {
      await _serverManager.load();
      await _userManager.restore();
      await _pushNotificationClient.initialize();
      await _installationManager.registerDevice(
          _pushNotificationClient, _userManager.currentUser);
      await _configurationLoader.reload();
      if (_userManager.currentUser != null) {
        context.read<AuthCubit>().setAuthorized(_userManager.currentUser);
        _serverManager.liveQueryManager.connect();
      } else {
        context.read<AuthCubit>().setUnauthorized();
      }
    } on Exception {
      context.read<AuthCubit>().setError();
    }
  }
}

class _AuthorizationScopeWidget extends InheritedWidget {
  final _AuthPageState state;

  const _AuthorizationScopeWidget({this.state, Key key, Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_AuthorizationScopeWidget old) => true;
}
