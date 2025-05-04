import 'dart:io';

enum AuthMode { signup, login }

class AuthFormData {
  String firstName = '';
  String lastName = '';
  String email = '';
  String password = '';
  String countryCode = '';
  String phone = '';
  String gender = '';
  String recoverEmail = '';
  String recoverPasswordEmail = '';
  String dateOfBirth = '';
  File? image;
  AuthMode? _mode;

  bool get isLogin {
    return _mode == AuthMode.login;
  }

  bool get isSignup {
    return _mode == AuthMode.signup;
  }

  void toggleAuthMode() {
    _mode = isLogin ? AuthMode.signup : AuthMode.login;
  }

  void setMode(String mode) {
    (mode == "login") ? _mode = AuthMode.login : _mode = AuthMode.signup;
  }
}
