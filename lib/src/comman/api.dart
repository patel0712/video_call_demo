// ignore_for_file: constant_identifier_names

class API {
  static const BASE_URL = 'https://reqres.in/api';

  // Authentication
  static const LOGIN = '$BASE_URL/login';
  static const REGISTER = '$BASE_URL/register';
}

class ApiConstants {
  static const String baseUrl = 'https://reqres.in/api';

  // Use 10.0.2.2 for Android emulator to access host localhost
  static const String awsChimeAndroidEmulator = 'http://10.0.2.2:5000';

  // Use localhost for iOS simulator or desktop
  static const String awsChimeLocalhost = 'http://192.168.181.115:5000';
}
