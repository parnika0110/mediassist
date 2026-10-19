import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_notification_service.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final NotificationService notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Mark all as read",
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              try {
                await notificationService.markAllAsRead(userId);

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("All notifications marked as read"),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notificationService.getNotifications(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        snapshot.error.toString(),
        style: const TextStyle(color: Colors.red),
      ),
    ),
  );
}

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Notifications", style: TextStyle(fontSize: 18)),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;

              final bool isRead = data['isRead'] ?? false;
              final String title = data['title'] ?? "";
              final String message = data['message'] ?? "";

              IconData icon = Icons.notifications;
              Color iconColor = Colors.blue;

              if (title.contains("Approved")) {
                icon = Icons.check_circle;
                iconColor = Colors.green;
              } else if (title.contains("Rejected")) {
                icon = Icons.cancel;
                iconColor = Colors.red;
              } else if (title.contains("Booked")) {
                icon = Icons.calendar_month;
                iconColor = Colors.orange;
              } else if (title.contains("Cancelled")) {
                icon = Icons.event_busy;
                iconColor = Colors.grey;
              }

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text("Delete Notification"),
                            content: const Text(
                              "Are you sure you want to delete this notification?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pop(dialogContext, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          );
                        },
                      ) ??
                      false;
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  try {
                    await notificationService.deleteNotification(doc.id);

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Notification deleted")),
                    );
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Card(
                  color: isRead ? Colors.white : Colors.lightBlue.shade50,
                  child: ListTile(
                    leading: Icon(icon, color: iconColor),
                    title: Text(
  title,
  style: TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontWeight:
        isRead ? FontWeight.normal : FontWeight.bold,
  ),
),

subtitle: Text(
  message,
  style: const TextStyle(
    color: Colors.black87,
  ),
),
                    trailing: !isRead
                        ? const Icon(Icons.circle, color: Colors.red, size: 10)
                        : null,
                    onTap: () async {
                      if (!isRead) {
                        try {
                          await notificationService.markAsRead(doc.id);
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
