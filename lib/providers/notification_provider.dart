import 'dart:async';
import 'package:flutter/material.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<List<AppNotification>>? _notifsSub;
  String? _currentUserId;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  void dispose() {
    _notifsSub?.cancel();
    super.dispose();
  }

  void subscribeToNotifications(String userId) {
    if (_currentUserId == userId && _notifsSub != null) return;
    _currentUserId = userId;

    _notifsSub?.cancel();
    _notifsSub = _notificationService.streamNotifications(userId).listen((list) {
      _notifications = list;
      notifyListeners();
    });
  }

  Future<void> fetchNotifications(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications(userId);
      subscribeToNotifications(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notifId) async {
    final index = _notifications.indexWhere((n) => n.id == notifId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
      await _notificationService.markAsRead(notifId);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();
    await _notificationService.markAllAsRead(userId);
  }

  Future<AppNotification> sendAdminNotification({
    required String userId,
    required String title,
    required String message,
    NotificationType type = NotificationType.adminReminder,
    String? actionRoute,
    Map<String, dynamic>? metaData,
  }) async {
    final notif = await _notificationService.sendAdminNotification(
      userId: userId,
      title: title,
      message: message,
      type: type,
      actionRoute: actionRoute,
      metaData: metaData,
    );

    _notifications.removeWhere((n) => n.id == notif.id);
    _notifications.insert(0, notif);
    notifyListeners();
    return notif;
  }
}
