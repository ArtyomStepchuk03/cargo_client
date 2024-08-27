import 'dart:async';
import 'package:flutter/material.dart';
import 'package:manager_mobile_client/src/logic/external/reachability.dart';
import 'package:manager_mobile_client/src/logic/external/push_notification_client.dart';
import 'package:manager_mobile_client/src/logic/server_manager/server_manager.dart';
import 'package:manager_mobile_client/src/logic/user_manager/installation_manager.dart';
import 'package:manager_mobile_client/src/logic/user_manager/user_manager.dart';
import 'package:manager_mobile_client/src/logic/user_manager/configuration_loader.dart';
import 'package:manager_mobile_client/src/ui/common/fullscreen_activity_widget.dart';
import 'package:manager_mobile_client/src/ui/format/user.dart';
import 'package:manager_mobile_client/src/ui/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/src/ui/main/main_widget.dart';
import 'log_in/log_in_widget.dart';
import 'authorization_error_widget.dart';
import 'no_internet_widget.dart';
import 'authorization_status.dart';
import 'authorization_strings.dart' as strings;

class AuthorizationWidget extends StatefulWidget {
  static AuthorizationState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AuthorizationScopeWidget>().state;
  }

  @override
  State createState() => AuthorizationState();
}

class AuthorizationState extends State<AuthorizationWidget> {
  AuthorizationState() : _status = AuthorizationStatus.loading(), _connected = false, _sessionChecked = false;

  void setLoading() => setState(() => _status = AuthorizationStatus.loading());
  void setErrored() => setState(() => _status = AuthorizationStatus.errored());
  void setAuthorized(User user) => setState(() => _status = AuthorizationStatus.authorized(user));
  void setUnauthorized({String message, String lastCompanyName, String lastUserName}) =>
    setState(() => _status = AuthorizationStatus.unauthorized(message: message, lastCompanyName: lastCompanyName, lastUserName: lastUserName));

  User get user => _status.user;
  String get message => _status.message;
  String get lastCompanyName => _status.lastCompanyName;
  String get lastUserName => _status.lastUserName;

  String get userTitle => formatUserSafe(user);

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
    return _AuthorizationScopeWidget(
      state: this,
      child: _buildContent(),
    );
  }

  Reachability _reachability;
  ServerManager _serverManager;
  InstallationManager _installationManager;
  UserManager _userManager;
  ConfigurationLoader _configurationLoader;
  PushNotificationClient _pushNotificationClient;

  AuthorizationStatus _status;
  bool _connected;

  bool _sessionChecked;
  StreamSubscription<bool> _reachabilitySubscription;

  Widget _buildContent() {
    if (_status.loading) {
      return _buildScaffold(FullscreenActivityWidget());
    }
    if (_status.authorized) {
      return MainWidget();
    }
    if (!_connected) {
      return _buildScaffold(NoInternetWidget());
    }
    if (_status.errored) {
      return _buildScaffold(AuthorizationErrorWidget(onRetry: _recheckSession));
    }
    return _buildScaffold(LogInWidget());
  }

  Widget _buildScaffold(Widget body) {
    return Scaffold(
      appBar: AppBar(title: Text(strings.title)),
      body: body,
    );
  }

  void _checkStatus() async {
    _connected = await _reachability.checkStatus();

    if (_connected) {
      _checkSession();
    } else {
      setUnauthorized();
    }

    _reachabilitySubscription = _reachability.onStatusChanged.listen((bool connected) {
      if (connected && !_sessionChecked) {
        setState(() {
          _status = AuthorizationStatus.loading();
          _connected = true;
        });
        _checkSession();
      } else {
        setState(() => _connected = connected);
      }
    });
  }

  void _recheckSession() {
    setLoading();
    _checkSession();
  }

  void _checkSession() async {
    _sessionChecked = true;
    try {
      await _serverManager.load();
      await _userManager.restore();
      await _pushNotificationClient.initialize();
      await _installationManager.registerDevice(_pushNotificationClient, _userManager.currentUser);
      await _configurationLoader.reload();
      if (_userManager.currentUser != null) {
        setAuthorized(_userManager.currentUser);
        _serverManager.liveQueryManager.connect();
      } else {
        setUnauthorized();
      }
    } on Exception {
      setErrored();
    }
  }
}

class _AuthorizationScopeWidget extends InheritedWidget {
  final AuthorizationState state;

  const _AuthorizationScopeWidget({this.state, Key key, Widget child}) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_AuthorizationScopeWidget old) => true;
}
