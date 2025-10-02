import 'package:flutter/services.dart';

abstract class PlatformScreenShare {
  static const MethodChannel _channel = MethodChannel('screen_share_plugin');

  static Future<bool> startScreenShare() async {
    try {
      print('📱 Calling native startScreenShare method...');
      final result = await _channel.invokeMethod('startScreenShare') ?? false;
      print('📱 Native startScreenShare result: $result');
      return result as bool;
    } on PlatformException catch (e) {
      print('❌ Error starting screen share: ${e.message}');
      return false;
    }
  }

  static Future<String> testPlugin() async {
    try {
      print('📱 Testing plugin communication...');
      final result = await _channel.invokeMethod('test') ?? 'No result';
      print('📱 Plugin test result: $result');
      return result as String;
    } on PlatformException catch (e) {
      print('❌ Error testing plugin: ${e.message}');
      return 'Error: ${e.message}';
    }
  }

  static Future<void> stopScreenShare() async {
    try {
      await _channel.invokeMethod('stopScreenShare');
    } on PlatformException catch (e) {
      print('Error stopping screen share: ${e.message}');
    }
  }
}
