class Validators {
  static String? validateIdentifier(String identifier) {
    if (identifier.isEmpty) {
      return 'Identifier cannot be empty';
    }
    // Add more validation logic as needed
    return null;
  }

  static String? validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email cannot be empty';
    }
    // Add more validation logic as needed
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }
    // Add more validation logic as needed
    return null;
  }
}
