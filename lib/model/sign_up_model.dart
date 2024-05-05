class SignUpModel {
  String? _userType;
  String? _name;
  String? _username;
  String? _email;
  String? _password;
  String? _confirmPassword;

  SignUpModel({
    String? userType,
    String? name,
    String? username,
    String? email,
    String? password,
    String? confirmPassword,
  })  : _userType = userType,
        _name = name,
        _username = username,
        _email = email,
        _password = password,
        _confirmPassword = confirmPassword;

  String? get userType => _userType;
  String? get name => _name;
  String? get username => _username;
  String? get email => _email;
  String? get password => _password;
  String? get confirmPassword => _confirmPassword;

   set userType(String? userType) {
    _userType = userType;
  }

   set name(String? name) {
    _name = name;
  }

   set username(String? username) {
    _username = username;
  }

   set email(String? email) {
    _email = email;
  }

   set password(String? password) {
    _password = password;
  }

   set confirmPassword(String? confirmPassword) {
    _confirmPassword = confirmPassword;
  }
}