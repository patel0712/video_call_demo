class ApiConfig {
  // Local testing base URL
  static String get apiUrl => const String.fromEnvironment(
    'AWS_CHIME_API_URL',
    defaultValue: 'http://192.168.181.115:5000/',
  );

  static String get region => const String.fromEnvironment(
    'AWS_CHIME_REGION',
    defaultValue: 'us-east-1',
  );

  /// Endpoint to create/join a meeting
  static String get joinMeetingUrl => '${apiUrl}join';

  /// Endpoint to end a meeting
  static String get endMeetingUrl => '${apiUrl}end';
}

/// flutter run \
///   --dart-define=AWS_CHIME_API_URL=http://localhost:5000/ \
///   --dart-define=AWS_CHIME_REGION=us-east-1
