class LoginModel {
  String? _email;
  String? _password;

  LoginModel({
    String? email,
    String? password,
  })  : _email = email,
        _password = password;

  String? get email => _email;
  String? get password => _password;

  set email(String? email) {
    _email = email;
  }

  set password(String? password) {
    _password = password;
  }
}