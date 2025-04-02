part of 'auth_cubit.dart';

class AuthState {
  AuthState({this.user, this.message, this.lastCompanyName, this.lastUserName});

  final User? user;
  final String? message;
  final String? lastCompanyName;
  final String? lastUserName;
}

class InitialAuthState extends AuthState {
  InitialAuthState(
      {User? user,
      String? message,
      String? lastCompanyName,
      String? lastUserName})
      : super(
            user: user,
            message: message,
            lastCompanyName: lastCompanyName,
            lastUserName: lastUserName);
}

class LoadingAuthState extends AuthState {
  LoadingAuthState(
      {User? user,
      String? message,
      String? lastCompanyName,
      String? lastUserName})
      : super(
            user: user,
            message: message,
            lastCompanyName: lastCompanyName,
            lastUserName: lastUserName);
}

class UnauthorizedAuthState extends AuthState {
  UnauthorizedAuthState(
      {User? user,
      String? message,
      String? lastCompanyName,
      String? lastUserName})
      : super(
            user: user,
            message: message,
            lastCompanyName: lastCompanyName,
            lastUserName: lastUserName);
}

class SuccessAuthState extends AuthState {
  SuccessAuthState(
      {User? user,
      String? message,
      String? lastCompanyName,
      String? lastUserName})
      : super(
            user: user,
            message: message,
            lastCompanyName: lastCompanyName,
            lastUserName: lastUserName);
}

class ErrorAuthState extends AuthState {
  ErrorAuthState(
      {User? user,
      String? message,
      String? lastCompanyName,
      String? lastUserName})
      : super(
            user: user,
            message: message,
            lastCompanyName: lastCompanyName,
            lastUserName: lastUserName);
}
