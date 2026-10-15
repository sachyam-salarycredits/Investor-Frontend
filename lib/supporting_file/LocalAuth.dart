import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class LocalAuth {
  static LocalAuthentication auth = LocalAuthentication();

  static Future<bool> canAuthWithBiometrics() async {
    return await auth.canCheckBiometrics;
  }

  static Future<bool> canAuth() async {
    return await auth.isDeviceSupported();
  }

  static Future<bool> authenticate() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to use PeerBridge',
          options: const AuthenticationOptions(useErrorDialogs: false));
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint("Authentication error ${e}");
      if (e.code == auth_error.notEnrolled) {
        // Add handling of no hardware here.
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        // ...
      } else {
        // ...
      }
      return false;
    }
  }
}
