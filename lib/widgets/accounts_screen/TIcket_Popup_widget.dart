import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';

import '../../utils/constants/colors.dart';
import '../../widgets/accounts_screen/ticket_detail_page.dart';

class SupportTicketsPage extends StatefulWidget {
  const SupportTicketsPage({super.key});

  @override
  State<SupportTicketsPage> createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends State<SupportTicketsPage> {
  final TextEditingController _ticketTitleController = TextEditingController();
  final TextEditingController _ticketDetailsController = TextEditingController();

  Stream<QuerySnapshot> _getTicketsStream() {
    String? userId = GetStorage().read("uid");
    if (userId == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection("support")
        .doc(userId)
        .collection("tickets")
        .orderBy("created_at", descending: true)
        .snapshots();
  }

  void _submitTicket() async {
    String? userId = GetStorage().read("uid");
    String? fullName = GetStorage().read("fullName");
    String? companyId = GetStorage().read("company_id");

    if (userId == null ||
        _ticketTitleController.text.isEmpty ||
        _ticketDetailsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill in all fields before submitting.")),
      );
      return;
    }

    String ticketId = const Uuid().v4();

    await FirebaseFirestore.instance
        .collection("support")
        .doc(userId)
        .collection("tickets")
        .doc(ticketId)
        .set({
      "ticketId": ticketId,
      "title": _ticketTitleController.text,
      "concern": _ticketDetailsController.text,
      "status": "Open",
      "reply": "",
      "created_at": FieldValue.serverTimestamp(),
      "userId": userId,
      "fullName": fullName,
      "companyId": companyId,
    });

    _ticketTitleController.clear();
    _ticketDetailsController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ticket submitted successfully.")),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return MyColors.color2;
      case 'In Progress':
        return MyColors.color1;
      case 'Resolved':
        return Colors.green;
      case 'Closed':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
                bottom: 0,
                left: 0,
                right: 0,
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            bool isLargeScreen = constraints.maxWidth > 1100;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? MediaQuery.of(context).size.width *.40 : 16,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _getTicketsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text("No support tickets found.");
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getStatusColor(ticket['status']),
                                child: const Icon(Icons.support_agent, color: Colors.white),
                              ),
                              title: Text(
                                ticket['title'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "Status: ${ticket['status']}",
                                style: TextStyle(color: _getStatusColor(ticket['status'])),
                              ),
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
                  const SizedBox(height: 32),
                  const Text(
                    'Submit a Support Ticket',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ticketTitleController,
                    decoration: const InputDecoration(
                      hintText: 'Ticket Title',
                      hintStyle: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _ticketDetailsController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Describe your issue...',
                      hintStyle: TextStyle(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _submitTicket,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 36),
                      decoration: BoxDecoration(
                        color: MyColors.color2,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),

      ),
    );
  }
}
