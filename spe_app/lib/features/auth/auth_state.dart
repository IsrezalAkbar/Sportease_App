import 'package:spe_app/data/models/user_model.dart';

class AuthState {
  final bool isLoading;
  final UserModel? user;

  const AuthState({this.isLoading = false, this.user});

  AuthState copyWith({bool? isLoading, UserModel? user}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
    );
  }
}
