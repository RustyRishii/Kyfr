class ApiConfig {
  const ApiConfig._();

  static const defaultBaseUrl = String.fromEnvironment(
    'KYFR_API_BASE_URL',
    defaultValue: 'https://kyfr.onrender.com',
  );

  static Uri uri(String baseUrl, String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalizedBase$path');
  }

  static Uri websocketUri(String baseUrl, String token) {
    final baseUri = Uri.parse(baseUrl);
    final scheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
    return baseUri.replace(
      scheme: scheme,
      path: '/ws',
      queryParameters: {'token': token},
    );
  }
}
