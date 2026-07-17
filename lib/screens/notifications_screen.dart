import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../theme/moni_theme.dart';
import '../providers/finance_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Local list of simulated notifications (often synced with FCM payloads)
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Daily Expense Reminder',
      'body': 'Don\'t forget to log your transactions for today to stay within your budget limit!',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
      'type': 'reminder',
    },
    {
      'id': '2',
      'title': 'Cloud Sync Completed',
      'body': 'All your transactions and savings goals were successfully backed up to Moni Cloud.',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
      'type': 'sync',
    },
    {
      'id': '3',
      'title': 'Budget Limit Warning',
      'body': 'You have consumed 85% of your food budget limit for this month.',
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': true,
      'type': 'alert',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoniTheme.background,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: MoniTheme.darkText,
        actions: [
          if (_notifications.any((n) => !n['isRead']))
            TextButton(
              onPressed: () {
                setState(() {
                  for (var n in _notifications) {
                    n['isRead'] = true;
                  }
                });
              },
              child: const Text('Mark all as read', style: TextStyle(color: Color(0xFF8A72F6), fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: SafeArea(
        child: _notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0EFFC),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_off_rounded, size: 48, color: Color(0xFF8A72F6)),
                    ),
                    const SizedBox(height: 16),
                    const Text('No notifications yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    const Text('We\'ll alert you on budgets & savings activity.', style: TextStyle(color: MoniTheme.mutedText, fontSize: 12)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final n = _notifications[index];
                  final bool isRead = n['isRead'];
                  final Color typeColor = n['type'] == 'alert'
                      ? Colors.redAccent
                      : (n['type'] == 'sync' ? Colors.green : const Color(0xFF8A72F6));

                  return Dismissible(
                    key: Key(n['id']),
                    onDismissed: (direction) {
                      setState(() {
                        _notifications.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification removed')),
                      );
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.white.withOpacity(0.7) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.015),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: isRead
                            ? null
                            : Border.all(color: const Color(0xFF8A72F6).withOpacity(0.12), width: 1.5),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        onTap: () {
                          setState(() {
                            n['isRead'] = true;
                          });
                        },
                        leading: CircleAvatar(
                          backgroundColor: typeColor.withOpacity(0.1),
                          child: Icon(
                            n['type'] == 'alert'
                                ? Icons.warning_amber_rounded
                                : (n['type'] == 'sync' ? Icons.sync_rounded : Icons.notifications_none_rounded),
                            color: typeColor,
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                n['title'],
                                style: TextStyle(
                                  fontWeight: isRead ? FontWeight.bold : FontWeight.w900,
                                  fontSize: 14,
                                  color: MoniTheme.darkText,
                                ),
                              ),
                            ),
                            Text(
                              DateFormat('jm').format(n['timestamp']),
                              style: const TextStyle(fontSize: 10, color: MoniTheme.mutedText),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            n['body'],
                            style: const TextStyle(fontSize: 12, color: MoniTheme.mutedText, height: 1.3),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
