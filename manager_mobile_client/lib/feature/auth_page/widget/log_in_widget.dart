import 'package:flutter/material.dart';
import 'package:manager_mobile_client/common/button.dart';
import 'package:manager_mobile_client/feature/auth_page/auth_page.dart';
import 'package:manager_mobile_client/feature/dependency/dependency_holder.dart';
import 'package:manager_mobile_client/util/localization_util.dart';
import 'package:manager_mobile_client/util/validators/required_validator.dart';

class LogInWidget extends StatefulWidget {
  @override
  State createState() => _LogInState();
}

class _LogInState extends State<LogInWidget> {
  _LogInState() : _showError = true;

  @override
  void dispose() {
    _userNameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: _buildForm(context));
  }

  bool _showError;
  final _formKey = GlobalKey<FormState>();
  final _companyNameKey = GlobalKey<FormFieldState<String>>();
  final _userNameKey = GlobalKey<FormFieldState<String>>();
  final _passwordKey = GlobalKey<FormFieldState<String>>();
  final _userNameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  Widget _buildForm(BuildContext context) {
    final localizationUtil = LocalizationUtil.of(context);
    final authorizationState = AuthPage.of(context);
    return Padding(
      padding: EdgeInsets.all(48),
      child: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  key: _companyNameKey,
                  initialValue: authorizationState.lastCompanyName,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration:
                      _buildDecoration(hintText: localizationUtil.companyName),
                  validator: RequiredValidator(context),
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(_userNameFocusNode),
                ),
                SizedBox(height: 12),
                TextFormField(
                  key: _userNameKey,
                  initialValue: authorizationState.lastUserName,
                  focusNode: _userNameFocusNode,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration:
                      _buildDecoration(hintText: localizationUtil.userName),
                  validator: RequiredValidator(context),
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(_passwordFocusNode),
                ),
                SizedBox(height: 12),
                TextFormField(
                  key: _passwordKey,
                  focusNode: _passwordFocusNode,
                  obscureText: true,
                  decoration:
                      _buildDecoration(hintText: localizationUtil.password),
                  validator: RequiredValidator(context),
                  onEditingComplete: _logIn,
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.all(16),
                    height: 44,
                    width: 160,
                    child: buildButton(
                      context,
                      child: Text(localizationUtil.logIn),
                      onPressed: _logIn,
                    ),
                  ),
                ),
                if (_showError && authorizationState.message != null)
                  Text(authorizationState.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildDecoration({String hintText}) {
    return InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor)));
  }

  void _logIn() async {
    final dependencyState = DependencyHolder.of(context);
    final authorizationState = AuthPage.of(context);
    final localizationUtil = LocalizationUtil.of(context);

    final serverManager = dependencyState.network.serverManager;
    final installationManager = dependencyState.network.installationManager;
    final configurationLoader = dependencyState.network.configurationLoader;
    final userManager = dependencyState.network.userManager;
    final pushNotificationClient =
        dependencyState.network.pushNotificationClient;

    setState(() => _showError = false);

    if (!_formKey.currentState.validate()) {
      return;
    }

    authorizationState.setLoading();

    final companyName = _companyNameKey.currentState.value;
    final userName = _userNameKey.currentState.value;
    final password = _passwordKey.currentState.value;

    try {
      await serverManager.configure(companyName);
      if (serverManager.server == null) {
        authorizationState.setUnauthorized(
            message: localizationUtil.companyError,
            lastCompanyName: companyName,
            lastUserName: userName);
        return;
      }

      await userManager.logIn(userName, password);
      if (userManager.currentUser == null) {
        authorizationState.setUnauthorized(
            message: localizationUtil.logInError,
            lastCompanyName: companyName,
            lastUserName: userName);
        return;
      }

      await pushNotificationClient.initialize();
      await installationManager.attachUser(
          pushNotificationClient, userManager.currentUser);
      await configurationLoader.reload();

      authorizationState.setAuthorized(userManager.currentUser);

      serverManager.liveQueryManager.connect();
      pushNotificationClient.requestPermissions();
    } on Exception {
      authorizationState.setUnauthorized(
          message: localizationUtil.errorOccurred,
          lastCompanyName: companyName,
          lastUserName: userName);
    }
  }
}
