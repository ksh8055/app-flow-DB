class AuthException implements Exception {
  final String message;
  final String code;
  
  AuthException(this.message, [this.code = 'auth-error']);

  @override
  String toString() => message;
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException() 
    : super('Invalid credentials provided', 'invalid-credentials');
}

class NetworkException extends AuthException {
  NetworkException() 
    : super('Network error. Please check your connection', 'network-error');
}

class AccountLockedException extends AuthException {
  AccountLockedException()
    : super('Account temporarily locked', 'account-locked');
}