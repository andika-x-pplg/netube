import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'channel_page.dart';

class SubscriptionsPage extends StatelessWidget {
  const SubscriptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Subscriptions",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('subscriptions')
            .doc(uid)
            .collection('channels')
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No subscriptions yet",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          final channels = snapshot.data!.docs;

          return ListView.builder(
            itemCount: channels.length,

            itemBuilder: (context, index) {
              final channel = channels[index].data() as Map<String, dynamic>;

              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChannelPage(
                        channelId: channel['channelId'],
                        channelName: channel['channelName'],
                      ),
                    ),
                  );
                },

                leading: const CircleAvatar(
                  backgroundColor: Colors.red,
                  child: Icon(Icons.person, color: Colors.white),
                ),

                title: Text(
                  channel['channelName'] ?? '',
                  style: const TextStyle(color: Colors.white),
                ),

                subtitle: const Text(
                  "Subscribed",
                  style: TextStyle(color: Colors.grey),
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
