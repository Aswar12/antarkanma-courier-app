class LoginRequest {
  final String identifier;
  final String password;

  LoginRequest({
    required this.identifier,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'identifier': identifier,
    'password': password,
  };

  // Named constructor for creating a request from stored credentials
  factory LoginRequest.fromCredentials(Map<String, String?> credentials) {
    final identifier = credentials['identifier'];
    final password = credentials['password'];

    if (identifier == null || password == null) {
      throw Exception('Invalid credentials: identifier and password are required');
    }

    return LoginRequest(
      identifier: identifier,
      password: password,
    );
  }
}
