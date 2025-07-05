import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../utils/constants/colors.dart';

class MonthlyJournalOverviewPage extends StatefulWidget {
  final DateTime? selectedDate;

  const MonthlyJournalOverviewPage({super.key, this.selectedDate});

  @override
  _MonthlyJournalOverviewPageState createState() =>
      _MonthlyJournalOverviewPageState();
}

class _MonthlyJournalOverviewPageState extends State<MonthlyJournalOverviewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late DateTime selectedMonth;
  late DateTime currentSelectedDate;

  Map<DateTime, List<String>> journalEntries = {}; // ✅ Store multiple entries per date

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.selectedDate ?? DateTime.now();
    currentSelectedDate = widget.selectedDate ?? DateTime.now();
    _fetchJournalEntries();
  }

  /// 🔍 Fetch all journal entries for the selected month from Firestore
  Future<void> _fetchJournalEntries() async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('Journals')
        .where('date', isGreaterThanOrEqualTo: DateFormat('yyyy-MM-dd').format(firstDay))
        .where('date', isLessThanOrEqualTo: DateFormat('yyyy-MM-dd').format(lastDay))
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        journalEntries.clear();
        for (var doc in snapshot.docs) {
          DateTime entryDate = DateTime.parse(doc['date']);
          List<String> notes = List<String>.from(doc['notes'] ?? []);
          journalEntries[entryDate] = notes; // ✅ Store multiple entries per date
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(selectedMonth.year, selectedMonth.month);
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 65,
          title: Text(
            DateFormat('MMMM y').format(selectedMonth),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalendarGrid(context, daysInMonth, firstDay),
              const SizedBox(height: 24),
              _buildJournalHighlights(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 📅 Build Calendar Grid
  Widget _buildCalendarGrid(BuildContext context, int daysInMonth, DateTime firstDay) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Journal Calendar', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: daysInMonth + firstDay.weekday - 1,
          itemBuilder: (context, index) {
            if (index < firstDay.weekday - 1) return Container();
            final day = index - firstDay.weekday + 2;
            final date = DateTime(selectedMonth.year, selectedMonth.month, day);

            return GestureDetector(
              onTap: () => _showJournalEntryPopup(context, date),
              child: CalendarDay(
                day: day,
                hasEntry: journalEntries.containsKey(date),
                isSelected: date == currentSelectedDate,
              ),
            );
          },
        ),
      ],
    );
  }

  /// 📝 Display Journal Highlights in a List
  Widget _buildJournalHighlights(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Journal History', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        if (journalEntries.isEmpty)
          const Text("No journal entries this month.", style: TextStyle(color: Colors.grey))
        else
          ...journalEntries.entries.map((entry) =>
              GestureDetector(
                onTap: () => _showJournalEntryPopup(context, entry.key),
                child: JournalHighlightCard(
                  date: entry.key,
                  preview: entry.value.join("\n"),
                ),
              )).toList(),
      ],
    );
  }

  /// 🔍 Show Popup to View or Edit Journal Entry
  void _showJournalEntryPopup(BuildContext context, DateTime date) {
    final bool hasEntry = journalEntries.containsKey(date);
    List<String> entries = hasEntry ? List<String>.from(journalEntries[date]!) : [];
    TextEditingController newEntryController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(
                DateFormat('MMMM dd, y').format(date),
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 📜 Styled List of Journal Entries
                    if (entries.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 250), // ✅ Prevents infinite expansion
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.withOpacity(0.5)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      entries[index],
                                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () {
                                          _editJournalEntry(context, date, index, entries, setState);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            entries.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "No entries yet.",
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                        ),
                      ),

                    // ✍ Input Field for New Entries
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: TextField(
                        controller: newEntryController,
                        decoration: InputDecoration(
                          hintText: "Write a new entry...",
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
                ),
                TextButton(
                  onPressed: () async {
                    if (newEntryController.text.trim().isNotEmpty) {
                      entries.add(newEntryController.text.trim());
                    }
                    await _saveJournalEntry(date, entries);
                    Navigator.pop(context);
                  },
                  child: Text("Save", style: GoogleFonts.poppins(fontSize: 14, color: Colors.blue)),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _editJournalEntry(BuildContext context, DateTime date, int index, List<String> entries, Function setState) {
    TextEditingController editController = TextEditingController(text: entries[index]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            "Edit Entry",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  entries[index] = editController.text.trim();
                });
                await _saveJournalEntry(date, entries);
                Navigator.pop(context);
              },
              child: Text("Save", style: GoogleFonts.poppins(fontSize: 14, color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }





  /// 💾 Save or Update Journal Entry
  Future<void> _saveJournalEntry(DateTime date, List<String> entries) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null || entries.isEmpty) return;

    await _firestore.collection('users').doc(uid).collection('Journals').doc(DateFormat('yyyy-MM-dd').format(date)).set({
      'date': DateFormat('yyyy-MM-dd').format(date),
      'notes': entries, // ✅ Correctly saves as a list
    }, SetOptions(merge: true));

    _fetchJournalEntries();
  }
}
// 📅 Calendar Day Widget with Journal Indicator (❤️ for entries)
class CalendarDay extends StatelessWidget {
  final int day;
  final bool hasEntry;
  final bool isSelected;

  const CalendarDay({super.key, required this.day, required this.hasEntry, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected ? MyColors.color2.withOpacity(0.5) : (hasEntry ? MyColors.color2.withValues(alpha: 0.1) : Colors.grey[100]),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: hasEntry ? MyColors.color2 : Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$day', style: TextStyle(
            fontWeight: hasEntry ? FontWeight.bold : FontWeight.normal,
            color: hasEntry ? MyColors.color1: Colors.grey,
          )),
          if (hasEntry) const Icon(Icons.favorite, color: Colors.red, size: 18),
        ],
      ),
    );
  }
}

// 📝 Journal Entry Highlights Widget
class JournalHighlightCard extends StatelessWidget {
  final DateTime date;
  final String preview;

  const JournalHighlightCard({super.key, required this.date, required this.preview});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.favorite, color: Colors.red, size: 24), // ❤️ Icon for journal history
            const SizedBox(width: 16),
            Expanded(
              child: Text(preview, style: GoogleFonts.poppins(), maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }}