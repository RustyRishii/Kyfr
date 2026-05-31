class AuthSession {
  const AuthSession({
    required this.token,
    required this.userId,
    required this.userName,
    required this.email,
  });

  final String token;
  final String userId;
  final String userName;
  final String email;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    if (user is! Map<String, dynamic>) {
      throw const FormatException('Auth response is missing user data');
    }

    return AuthSession(
      token: json['token'] as String,
      userId: user['id'] as String,
      userName: user['name'] as String,
      email: user['email'] as String,
    );
  }
}
