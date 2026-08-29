import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_notification.dart';

class NotificationService {
  FirebaseFirestore? _firestore;
  bool _isFirebaseAvailable = false;

  NotificationService() {
    try {
      _firestore = FirebaseFirestore.instance;
      _isFirebaseAvailable = true;
    } catch (_) {
      _isFirebaseAvailable = false;
    }
  }

  // Real-time stream of notifications for patient app
  Stream<List<AppNotification>> streamNotifications(String userId) {
    if (_isFirebaseAvailable && _firestore != null) {
      return _firestore!
          .collection('notifications')
          .snapshots()
          .handleError((e) {
        debugPrint('Notification stream notice: $e');
      }).map((snapshot) {
        final list = snapshot.docs
            .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
            .where((n) => n.userId == userId || n.userId == 'all_patients' || userId.isEmpty)
            .toList();
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return list;
      });
    }
    return Stream.value([]);
  }

  // Get notifications for user
  Future<List<AppNotification>> getNotifications(String userId) async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        final query = await _firestore!
            .collection('notifications')
            .get();

        if (query.docs.isNotEmpty) {
          final list = query.docs
              .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
              .where((n) => n.userId == userId || n.userId == 'all_patients' || userId.isEmpty)
              .toList();
          list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return list;
        }
      } catch (_) {}
    }

    // Local / fallback
    final local = await _getLocalNotifications();
    if (local.isNotEmpty) {
      final filtered = local
          .where((n) => n.userId == userId || n.userId == 'all_patients' || userId.isEmpty)
          .toList();
      filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return filtered;
    }

    return [];
  }

  // Send admin notification (Admin panel trigger)
  Future<AppNotification> sendAdminNotification({
    required String userId,
    required String title,
    required String message,
    NotificationType type = NotificationType.adminReminder,
    String? actionRoute,
    Map<String, dynamic>? metaData,
  }) async {
    final notifId = 'NOTIF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final notif = AppNotification(
      id: notifId,
      userId: userId,
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      actionRoute: actionRoute,
      metaData: metaData,
    );

    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('notifications').doc(notifId).set(notif.toMap());
      } catch (_) {}
    }

    await _saveNotificationLocally(notif);
    return notif;
  }

  // Mark single as read
  Future<void> markAsRead(String notifId) async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        await _firestore!.collection('notifications').doc(notifId).update({'isRead': true});
      } catch (_) {}
    }

    final local = await _getLocalNotifications();
    final updated = local.map((n) {
      if (n.id == notifId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    await _saveAllNotificationsLocally(updated);
  }

  // Mark all as read
  Future<void> markAllAsRead(String userId) async {
    if (_isFirebaseAvailable && _firestore != null) {
      try {
        final batch = _firestore!.batch();
        final query = await _firestore!
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .get();
        for (final doc in query.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      } catch (_) {}
    }

    final local = await _getLocalNotifications();
    final updated = local.map((n) {
      if (n.userId == userId || n.userId == 'all_patients') {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    await _saveAllNotificationsLocally(updated);
  }

  Future<void> _saveNotificationLocally(AppNotification notification) async {
    final existing = await _getLocalNotifications();
    existing.removeWhere((n) => n.id == notification.id);
    existing.insert(0, notification);
    await _saveAllNotificationsLocally(existing);
  }

  Future<void> _saveAllNotificationsLocally(List<AppNotification> list) async {
    final prefs = await SharedPreferences.getInstance();
    final data = list.map((n) => n.toMap()..['id'] = n.id).toList();
    await prefs.setString('precisioncare_notifications', jsonEncode(data));
  }

  Future<List<AppNotification>> _getLocalNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('precisioncare_notifications');
    if (raw == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded
          .map((e) => AppNotification.fromMap(Map<String, dynamic>.from(e), e['id'] ?? ''))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
