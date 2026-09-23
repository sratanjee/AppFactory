import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

const int _followUpChannelId = 3001;

/// Local-notification wrapper. Fires "Quote to {name} sent 3 days ago,
/// follow up?" 3 days after a quote transitions to `sent`; the reminder
/// is cancelled the moment the job moves to `accepted` / `invoiced` /
/// `paid`.
///
/// Wire this behind an opt-in prompt after the first PDF send (PLAN §6).
class FollowUpNotifications {
  FollowUpNotifications({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> _ensureReady() async {
    if (_initialized) return;
    const settings = InitializationSettings(
      iOS: DarwinInitializationSettings(),
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await _ensureReady();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(alert: true, badge: true);
      return granted ?? false;
    }
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  /// Schedule the follow-up. Same job number always maps to the same
  /// notification id, so a rescheduled quote overwrites the previous
  /// reminder.
  Future<void> scheduleFollowUp({
    required int jobNumber,
    required String customerName,
    required DateTime fireAt,
  }) async {
    await _ensureReady();
    await _plugin.zonedSchedule(
      id: _followUpChannelId + jobNumber,
      title: 'Quote to $customerName sent 3 days ago',
      body: 'Follow up?',
      scheduledDate: tz.TZDateTime.from(fireAt, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'follow_up',
          'Follow-up reminders',
          channelDescription:
              "Reminds you to follow up on quotes that haven't been accepted.",
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelFollowUp(int jobNumber) async {
    await _ensureReady();
    await _plugin.cancel(id: _followUpChannelId + jobNumber);
  }
}

final followUpNotificationsProvider = Provider<FollowUpNotifications>((ref) {
  return FollowUpNotifications();
});
