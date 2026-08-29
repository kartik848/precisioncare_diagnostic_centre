import 'package:flutter/services.dart';

class VibrationHelper {
  /// Trigger a noticeable dual-pulse vibration for incoming notifications
  static Future<void> triggerNotificationVibration() async {
    try {
      // First pulse
      await HapticFeedback.vibrate();
      await HapticFeedback.heavyImpact();
      
      // Short delay between pulses for realistic alert vibration
      await Future.delayed(const Duration(milliseconds: 180));
      
      // Second pulse
      await HapticFeedback.vibrate();
      await HapticFeedback.heavyImpact();
    } catch (_) {
      // Fallback
      try {
        await HapticFeedback.vibrate();
      } catch (_) {}
    }
  }

  /// Light haptic feedback for user taps & button presses
  static Future<void> lightFeedback() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }
}
