import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:llps_mental_app/widgets/accounts_screen/ticket_detail_page.dart';
import 'package:uuid/uuid.dart';

import '../../utils/constants/colors.dart';

class SupportTicketsPage extends StatefulWidget {
  @override
  _SupportTicketsPageState createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends State<SupportTicketsPage> {
  final TextEditingController _ticketTitleController = TextEditingController();
  final TextEditingController _ticketDetailsController = TextEditingController();

  /// ✅ Fetch tickets dynamically from Firestore
  Stream<QuerySnapshot> _getTicketsStream() {
    String? userId = GetStorage().read("uid");
    if (userId == null) return Stream.empty();

    return FirebaseFirestore.instance
        .collection("support").doc(userId)
        .collection("tickets")
        .orderBy("created_at", descending: true)
        .snapshots();
  }

  /// ✅ Submit ticket to Firestore
  void _submitTicket() async {
    String? userId = GetStorage().read("uid");
    String? fullName = GetStorage().read("fullName");
    String? companyId = GetStorage().read("company_id");

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found. Please log in.")),
      );
      return;
    }

    if (_ticketTitleController.text.isEmpty || _ticketDetailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in both fields before submitting.")),
      );
      return;
    }

    String ticketId = const Uuid().v4(); // ✅ Generate unique ticket ID

    try {
      await FirebaseFirestore.instance.collection("support").doc(userId)
          .collection("tickets").doc(ticketId).set({
        "ticketId": ticketId,
        "title": _ticketTitleController.text,
        "concern": _ticketDetailsController.text,
        "status": "Open",
        "reply": "",
        "created_at": FieldValue.serverTimestamp(),
        "userId": userId, // Add the userId to the ticket
        "fullName": fullName, // Add user's full name
        "companyId": companyId, // Add the companyId to the ticket
      });

      print(companyId);

      _ticketTitleController.clear();
      _ticketDetailsController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ticket submitted successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting ticket: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Support Tickets'),
          toolbarHeight: 65,
          flexibleSpace: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF8F8F8), Color(0xFFF1F1F1)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Colors.orangeAccent, Colors.green, Colors.greenAccent],
                      stops: const [0.0, 0.5, 0.5, 1.0],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getTicketsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No support tickets found."));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var ticket = snapshot.data!.docs[index];

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5, offset: const Offset(0, 3)),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(ticket['status']),
                              child: const Icon(Icons.support_agent, color: Colors.white),
                            ),
                            title: Text(ticket['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                            subtitle: Text("Status: ${ticket['status']}", style: TextStyle(color: _getStatusColor(ticket['status']))),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TicketDetailPage(ticketId: ticket.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              const Text('Submit a Support Ticket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 15),
              TextField(
                controller: _ticketTitleController,
                decoration: const InputDecoration(hintText: 'Ticket Title', hintStyle: TextStyle(color: Colors.black54)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ticketDetailsController,
                decoration: const InputDecoration(hintText: 'Describe your issue...', hintStyle: TextStyle(color: Colors.black54)),
                maxLines: 5,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _submitTicket,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 36),
                  decoration: BoxDecoration(
                    color: MyColors.color2,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5, offset: const Offset(0, 3))],
                  ),
                  child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open': return MyColors.color2;
      case 'In Progress': return MyColors.color1;
      case 'Resolved': return Colors.green;
      case 'Closed': return Colors.grey;
      default: return Colors.black;
    }
  }
}

