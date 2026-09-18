import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/app_notification.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/empty_state.dart';
import '../booking/schedule_booking_screen.dart';
import '../reports/reports_screen.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<NotificationProvider>().fetchNotifications(
          user.uid,
          userMobile: user.mobile,
          userEmail: user.email,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications & Reminders'),
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                if (user != null) {
                  notifProvider.markAllAsRead(user.uid);
                }
              },
              child: Text(
                'Mark all read',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'No Notifications Yet',
              description: 'You will receive notifications here for upcoming tests, sample collection updates, admin reminders, and verified reports.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(notifications[index]);
              },
            ),
    );
  }

  Widget _buildNotificationCard(AppNotification notif) {
    final isUnread = !notif.isRead;

    IconData iconData;
    Color iconColor;
    Color bgColor;

    switch (notif.type) {
      case NotificationType.nextTestDue:
      case NotificationType.adminReminder:
        iconData = Icons.alarm_rounded;
        iconColor = AppColors.primary;
        bgColor = AppColors.primaryLight;
        break;
      case NotificationType.reportReady:
        iconData = Icons.description_rounded;
        iconColor = AppColors.success;
        bgColor = AppColors.successLight;
        break;
      case NotificationType.bookingUpdate:
        iconData = Icons.local_shipping_rounded;
        iconColor = AppColors.primaryDark;
        bgColor = AppColors.primaryLight;
        break;
      case NotificationType.healthTip:
        iconData = Icons.tips_and_updates_rounded;
        iconColor = AppColors.info;
        bgColor = AppColors.infoLight;
        break;
    }

    return GestureDetector(
      onTap: () {
        if (!notif.isRead) {
          context.read<NotificationProvider>().markAsRead(notif.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? Colors.white : AppColors.background.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnread ? const Color(0xFFFECDD3) : AppColors.border,
            width: isUnread ? 1.5 : 1,
          ),
          boxShadow: isUnread
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, size: 22, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.message,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Timestamp & Action Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormatter.getRelativeTime(notif.timestamp),
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      ),
                      if (notif.type == NotificationType.nextTestDue || notif.type == NotificationType.adminReminder)
                        InkWell(
                          onTap: () {
                            context.read<NotificationProvider>().markAsRead(notif.id);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ScheduleBookingScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Schedule Now',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                                const SizedBox(width: 3),
                                const Icon(Icons.arrow_forward_rounded, size: 10, color: Colors.white),
                              ],
                            ),
                          ),
                        )
                      else if (notif.type == NotificationType.reportReady)
                        InkWell(
                          onTap: () {
                            context.read<NotificationProvider>().markAsRead(notif.id);
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ReportsScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View Report',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                                const SizedBox(width: 3),
                                const Icon(Icons.download_rounded, size: 10, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
