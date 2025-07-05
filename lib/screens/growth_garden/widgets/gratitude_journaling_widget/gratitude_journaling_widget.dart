import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../utils/constants/colors.dart';
import '../../monthlyjournaloverviewpage.dart';

class GratitudeJournalWidget extends StatefulWidget {

  @override
  _GratitudeJournalWidgetState createState() => _GratitudeJournalWidgetState();
}

class _GratitudeJournalWidgetState extends State<GratitudeJournalWidget> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, List<String>> journalEntries = {};
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  DateTime selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Add static data to journalEntries

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            MyColors.color1,
            Colors.green,
            Colors.orange,
            MyColors.color2
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            _headerSection(),
            const Divider(height: 1, color: Colors.black38),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _journalListView(),
                  _buildAddEntryButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gratitude Journal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MyColors.color1,
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => MonthlyJournalOverviewPage());
                  },
                  child: const Icon(
                      Icons.calendar_today, size: 18, color: MyColors.color1),
                ),
                SizedBox(width: 15),
                GestureDetector(
                  onTap: () =>

                      selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: MyColors.color1,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          DateFormat('MMM d, yyyy').format(DateTime.parse(
                              currentDate)),
                          style: const TextStyle(color: Colors.white,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _journalListView() {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Center(child: Text('User not logged in.'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection('users')
          .doc(uid)
          .collection('Journals')
          .doc(currentDate) // Fetches journal entries for the selected date
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'No entries for today.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          );
        }

        List<String> entries = List<String>.from(
            snapshot.data!.get('notes') ?? []);

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          itemBuilder: (context, index) =>
              Dismissible(
                key: UniqueKey(),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await _showDeleteDialog(context);
                },
                onDismissed: (direction) async {
                  await _deleteJournalEntry(uid, currentDate, entries[index]);
                },
                child: _journalTile(entries[index], index),
              ),
        );
      },
    );
  }

  Future<void> _deleteJournalEntry(String uid, String date,
      String entry) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('Journals')
        .doc(date)
        .update({
      'notes': FieldValue.arrayRemove([entry]),
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting entry: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }


  Widget _buildAddEntryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
      child: GestureDetector(
        onTap: () => _showJournalDialog(context),
        child: Container(
          height: 50,
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: MyColors.color2,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Opacity(
                  opacity: 1,
                  child: Icon(
                      Icons.add, size: 15, color: Colors.white, weight: 800),
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'ADD GRATITUDE ENTRY',
                style: TextStyle(fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          // Rounded corners
          titlePadding: const EdgeInsets.all(16),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delete Entry',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: const Icon(Icons.close, color: Colors.black54, size: 20),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 10),
          content: const Text(
            'Are you sure you want to delete this entry?',
            style: TextStyle(fontSize: 16),
          ),
          actionsPadding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 8),
          actions: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8), // Reduced spacing between buttons
                  GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: MyColors.color2),
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: MyColors.color2,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _journalTile(String entry, int index) {
    return GestureDetector(
      onTap: () => _editJournalEntry(context, index, entry),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MyColors.color1.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                entry,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),

          ],
        ),
      ),
    );
  }


  void _showJournalDialog(BuildContext context,
      {int? index, String? oldEntry}) {
    TextEditingController _controller = TextEditingController(
        text: oldEntry ?? "");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            index == null ? 'Add Gratitude Entry' : 'Edit Gratitude Entry',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'I am grateful for...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () async {
                String entry = _controller.text.trim();
                if (entry.isNotEmpty) {
                  final String? uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    if (index == null) {
                      // Adding a new entry
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .collection('Journals')
                          .doc(currentDate)
                          .set({
                        'date': currentDate,
                        'notes': FieldValue.arrayUnion([entry]),
                      }, SetOptions(merge: true));
                    } else {
                      // Editing an existing entry
                      await _updateJournalEntry(
                          uid, currentDate, oldEntry!, entry);
                    }

                    Navigator.pop(context);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please write something before saving.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateJournalEntry(String uid, String date, String oldEntry,
      String newEntry) async {
    DocumentReference docRef = _firestore.collection('users')
        .doc(uid)
        .collection('Journals')
        .doc(date);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      List<String> notes = List<String>.from(snapshot.get('notes') ?? []);

      // Replace old entry with the new entry0
      if (notes.contains(oldEntry)) {
        notes[notes.indexOf(oldEntry)] = newEntry;
      }

      // Update Firestore document with new list
      transaction.update(docRef, {'notes': notes});
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating entry: $error'),
            backgroundColor: Colors.red),
      );
    });
  }


  void _editJournalEntry(BuildContext context, int index, String entry) {
    _showJournalDialog(context, index: index, oldEntry: entry);
  }

  Future<void> selectDate(BuildContext context) async {
    selectedMonth = DateTime.now(); // Set selectedMonth to the current month

    // Fetch Firestore data before opening calendar
    await fetchMonthlyJournals();

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        final daysInMonth = DateUtils.getDaysInMonth(selectedMonth.year, selectedMonth.month);
        final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
        String selectedDate = currentDate;

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMMM y').format(selectedMonth),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 250,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: daysInMonth + (firstDay.weekday - 1),
                      itemBuilder: (context, index) {
                        if (index < firstDay.weekday - 1) return Container();
                        final day = index - (firstDay.weekday - 1) + 1;
                        final date = DateTime(selectedMonth.year, selectedMonth.month, day);
                        final formattedDate = DateFormat('yyyy-MM-dd').format(date);
                        final hasEntry = journalEntries.containsKey(formattedDate);
                        final isSelected = selectedDate == formattedDate;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDate = formattedDate;
                            });
                          },
                          child: CalendarDay(
                            day: day,
                            hasEntry: hasEntry,  // ✅ Firestore data is now correctly checked
                            isSelected: isSelected,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      if (selectedDate.isNotEmpty) {
                        setState(() {
                          currentDate = selectedDate; // Update main state
                        });

                        // Reload UI in main state
                        if (mounted) {
                          this.setState(() {}); // Reload journal data for new date
                        }

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Selected Date: $selectedDate"),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: MyColors.color2,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 1,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        "Check Date",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }



  Future<void> fetchMonthlyJournals() async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    String startOfMonth = DateFormat('yyyy-MM-01').format(selectedMonth);
    String endOfMonth = DateFormat('yyyy-MM-dd').format(
        DateTime(selectedMonth.year, selectedMonth.month + 1, 0));

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('Journals')
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: startOfMonth)
        .where(FieldPath.documentId, isLessThanOrEqualTo: endOfMonth)
        .get();

    setState(() {
      journalEntries.clear();
      for (var doc in snapshot.docs) {
        journalEntries[doc.id] = List<String>.from(doc['notes'] ?? []);
      }
    });
  }


}