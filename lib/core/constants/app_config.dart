class AppConfig {
  AppConfig._();

  // Environment-based keys
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: '',
  );

  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );
  
  // App Metadata
  static const String appName = 'GradPass';
}