import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:prime/providers/task_provider.dart';

class NotificationProvider with ChangeNotifier {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final TaskProvider _taskProvider;

  NotificationProvider(this._taskProvider) {
    _initializeNotifications();
    _taskProvider.addListener(_scheduleTaskNotifications);
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  Future<void> _scheduleTaskNotifications() async {
    // Cancel all existing notifications
    await _notifications.cancelAll();

    // Schedule notifications for upcoming tasks
    final now = DateTime.now();
    final tasks = _taskProvider.tasks.where((task) => 
      !task.isCompleted && 
      task.dueDate.isAfter(now)
    );

    for (final task in tasks) {
      // Schedule notification for 1 hour before due date
      final notificationTime = task.dueDate.subtract(const Duration(hours: 1));
      
      if (notificationTime.isAfter(now)) {
        await _scheduleNotification(
          id: task.id.hashCode,
          title: 'یادآوری تسک',
          body: 'تسک "${task.title}" تا یک ساعت دیگر موعد مقرر آن است.',
          scheduledDate: notificationTime,
        );
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for task reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: 
        UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showTaskCompletedNotification(Task task) async {
    await _notifications.show(
      task.id.hashCode,
      'تسک تکمیل شد',
      'تسک "${task.title}" با موفقیت تکمیل شد.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'task_completion',
          'Task Completion',
          channelDescription: 'Notifications for completed tasks',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _taskProvider.removeListener(_scheduleTaskNotifications);
    super.dispose();
  }
} 