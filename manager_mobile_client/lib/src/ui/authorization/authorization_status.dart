import 'package:manager_mobile_client/src/logic/concrete_data/user.dart';

export 'package:manager_mobile_client/src/logic/concrete_data/user.dart';

class AuthorizationStatus {
  final User user;
  final String message;
  final String lastCompanyName;
  final String lastUserName;

  AuthorizationStatus.loading() : this._(_AuthorizationStatusCode.loading);
  AuthorizationStatus.errored() : this._(_AuthorizationStatusCode.errored);
  AuthorizationStatus.authorized(User user) : this._(_AuthorizationStatusCode.authorized, user: user);
  AuthorizationStatus.unauthorized({String message, String lastCompanyName, String lastUserName}) :
    this._(_AuthorizationStatusCode.unauthorized, message: message, lastCompanyName: lastCompanyName, lastUserName: lastUserName);

  bool get loading => _code == _AuthorizationStatusCode.loading;
  bool get errored => _code == _AuthorizationStatusCode.errored;
  bool get authorized => _code == _AuthorizationStatusCode.authorized;
  bool get unauthorized => _code == _AuthorizationStatusCode.unauthorized;

  final _AuthorizationStatusCode _code;

  AuthorizationStatus._(this._code, {this.user, this.message, this.lastCompanyName, this.lastUserName});
}

enum _AuthorizationStatusCode {
  loading,
  errored,
  authorized,
  unauthorized,
}
