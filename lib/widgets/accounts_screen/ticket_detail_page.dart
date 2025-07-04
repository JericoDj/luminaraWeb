import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';

class TicketDetailPage extends StatefulWidget {
  final String ticketId;

  const TicketDetailPage({required this.ticketId, super.key});

  @override
  _TicketDetailPageState createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  /// ✅ Fetch messages stream from Firestore
  Stream<QuerySnapshot> _getMessagesStream(String userId, String ticketId) {
    return FirebaseFirestore.instance
        .collection("support").doc(userId)
        .collection("tickets").doc(ticketId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  /// ✅ Send message to Firestore
  void _sendMessage() async {
    String? userId = GetStorage().read("uid");
    if (userId == null || _messageController.text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection("support").doc(userId)
          .collection("tickets").doc(widget.ticketId)
          .collection("messages").add({
        "message": _messageController.text.trim(),
        "sender": "User",
        "timestamp": FieldValue.serverTimestamp(),
      });

      _messageController.clear();
      _focusNode.requestFocus(); // Keep focus on input field
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending message: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String? userId = GetStorage().read("uid");
    Color sendButtonColor = Theme.of(context).primaryColor; // Dynamic theme color

    return Scaffold(
      appBar: AppBar(title: const Text("Ticket Details")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("support").doc(userId)
            .collection("tickets").doc(widget.ticketId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          var ticket = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Title: ${ticket["title"]}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text("Concern: ${ticket["concern"]}", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 20),
                      Text("Status: ${ticket["status"]}", style: TextStyle(fontSize: 16, color: _getStatusColor(ticket["status"]))),
                      const Divider(),
                      const SizedBox(height: 10),
                      const Text("Messages", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _getMessagesStream(userId!, widget.ticketId),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                            var messages = snapshot.data!.docs;

                            return messages.isEmpty
                                ? const Center(child: Text("No messages yet."))
                                : ListView.builder(
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                var message = messages[index];
                                bool isUser = message["sender"] == "User";

                                return Align(
                                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isUser ? Colors.blue[50] : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isUser ? "You" : "Support",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: isUser ? Colors.blue : Colors.red,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          message["message"],
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: "Type your message...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: CircleAvatar(
                        backgroundColor: sendButtonColor,
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ✅ Function to get the appropriate status color
Color _getStatusColor(String status) {
  switch (status) {
    case 'Open': return Colors.orange;
    case 'In Progress': return Colors.blue;
    case 'Resolved': return Colors.green;
    case 'Closed': return Colors.grey;
    default: return Colors.black;
  }
}
