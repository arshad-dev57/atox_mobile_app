import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/constants.dart';
import '../../../../services/database_service.dart';
import '../../../../models/notification_model.dart';
import '../../../../providers/user_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final user = Provider.of<UserProvider>(context, listen: false).userData;
    if (user != null && user.uid != null) {
      final notifs = await DatabaseService().getUserNotifications(user.uid!);
      if (mounted) {
        setState(() {
          _notifications = notifs;
          _loading = false;
        });
      }
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: _loading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_outlined, size: 64, color: AppColors.textTertiary),
                  const SizedBox(height: 16),
                  const Text('No notifications yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  const Text('When your requests are approved, they will appear here.', style: TextStyle(fontSize: 14, color: AppColors.textTertiary), textAlign: TextAlign.center),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notif = _notifications[index];
                  final isSuccess = notif.type == 'success';
                  final isError = notif.type == 'error';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSuccess ? Colors.green.withOpacity(0.1) : (isError ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isSuccess ? Icons.check_circle : (isError ? Icons.error : Icons.notifications),
                            color: isSuccess ? Colors.green : (isError ? Colors.red : Colors.blue),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notif.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text(notif.message, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
                              const SizedBox(height: 8),
                              Text(notif.createdAt.toString().substring(0, 16), style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
