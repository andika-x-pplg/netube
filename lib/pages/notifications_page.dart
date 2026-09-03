import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/notification_service.dart';
import '../theme/netube_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NetubeColors.background,

      appBar: AppBar(
        backgroundColor: NetubeColors.background,
        elevation: 0,

        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: NotificationService.getNotifications(),

        builder: (context, snapshot) {
          // ==========================
          // ERROR
          // ==========================
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Gagal memuat notifikasi",
                style: TextStyle(color: Colors.red.shade300),
              ),
            );
          }

          // ==========================
          // LOADING
          // ==========================
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          // ==========================
          // KOSONG
          // ==========================
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, color: Colors.grey, size: 60),

                  SizedBox(height: 15),

                  Text(
                    "Belum ada notifikasi",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          // ==========================
          // LIST NOTIFICATION
          // ==========================
          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: notifications.length,

            itemBuilder: (context, index) {
              final notificationDoc = notifications[index];

              final notification =
                  notificationDoc.data() as Map<String, dynamic>;

              final isRead = notification["isRead"] ?? false;
              final createdAt = notification["createdAt"];
              final timestamp = createdAt is Timestamp
                  ? timeago.format(createdAt.toDate())
                  : "Just now";

              return InkWell(
                borderRadius: BorderRadius.circular(16),

                onTap: () async {
                  if (!isRead) {
                    await NotificationService.markAsRead(notificationDoc.id);
                  }
                },

                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),

                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: isRead
                        ? NetubeColors.surface
                        : const Color(0xFF241416),

                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // ICON
                      Container(
                        width: 42,
                        height: 42,

                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 21,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              notification["message"] ?? "Notifikasi baru",

                              style: TextStyle(
                                color: Colors.white,

                                fontSize: 14,

                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              timestamp,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // TITIK BELUM DIBACA
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,

                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
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
