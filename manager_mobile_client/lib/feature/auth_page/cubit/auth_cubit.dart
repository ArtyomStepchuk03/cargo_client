import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manager_mobile_client/feature/messages_page/widget/message_write/user_data_source.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(InitialAuthState());

  void setLoading() {
    emit(LoadingAuthState(
        user: state.user,
        message: state.message,
        lastCompanyName: state.lastCompanyName,
        lastUserName: state.lastUserName));
  }

  void setUnauthorized(
      {String message, String lastCompanyName, String lastUserName}) {
    if (message == null) {
      message = state.message;
    }

    if (lastCompanyName == null) {
      lastCompanyName = state.lastCompanyName;
    }

    if (lastUserName == null) {
      lastUserName = state.lastUserName;
    }

    emit(UnauthorizedAuthState(
        user: state.user,
        message: message,
        lastCompanyName: lastCompanyName,
        lastUserName: lastUserName));
  }

  void setAuthorized(User user) {
    if (user == null) {
      user = state.user;
    }

    emit(SuccessAuthState(
        user: user,
        message: state.message,
        lastCompanyName: state.lastCompanyName,
        lastUserName: state.lastUserName));
  }

  void setError() {
    emit(ErrorAuthState(
        user: state.user,
        message: state.message,
        lastCompanyName: state.lastCompanyName,
        lastUserName: state.lastUserName));
  }
}
