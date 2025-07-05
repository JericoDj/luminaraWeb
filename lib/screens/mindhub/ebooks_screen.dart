import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class EbookItem {
  final String title;
  final String description;
  final String coverUrl;
  final String pdfUrl;
  final int order;

  const EbookItem({
    required this.title,
    required this.description,
    required this.coverUrl,
    required this.pdfUrl,
    required this.order,
  });

  factory EbookItem.fromMap(Map<String, dynamic> map) {
    return EbookItem(
      title: map['title'] ?? 'Untitled',
      description: map['description'] ?? 'No description',
      coverUrl: map['coverUrl'] ?? '',
      pdfUrl: map['pdfUrl'] ?? '',
      order: map['order'] ?? 0,
    );
  }
}

class MindHubEbooksScreen extends StatefulWidget {
  const MindHubEbooksScreen({Key? key}) : super(key: key);

  @override
  State<MindHubEbooksScreen> createState() => _MindHubEbooksScreenState();
}

class _MindHubEbooksScreenState extends State<MindHubEbooksScreen> {
  Future<List<EbookItem>> _fetchEbooksFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('contents')
          .doc('ebooks')
          .get();

      if (!doc.exists) return [];

      final data = doc.data()!;
      final List<EbookItem> ebooks = [];

      data.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          ebooks.add(EbookItem.fromMap(value));
        }
      });

      ebooks.sort((a, b) => a.order.compareTo(b.order));
      return ebooks;
    } catch (e) {
      print('Error fetching ebooks: $e');
      return [];
    }
  }

  Future<void> openEbook(String pdfUrl) async {
    try {
      final Uri url = Uri.parse(pdfUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the PDF')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder<List<EbookItem>>(
        future: _fetchEbooksFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No ebooks available'));
          }

          final ebooks = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: ebooks.length,
            itemBuilder: (context, index) {
              final ebook = ebooks[index];
              return GestureDetector(
                onTap: () => openEbook(ebook.pdfUrl),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                          child: Image.network(
                            ebook.coverUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[200],
                              alignment: Alignment.center,
                              child: const Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ebook.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ebook.description,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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