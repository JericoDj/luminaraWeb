import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luminarawebsite/Footer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/constants/colors.dart';

class SafeSpaceHubArticles extends StatelessWidget {
  const SafeSpaceHubArticles({Key? key}) : super(key: key);

  Future<List<Article>> _fetchArticles() async {
    final doc = await FirebaseFirestore.instance.collection('contents').doc('articles').get();

    if (!doc.exists) return [];

    final data = doc.data()!;
    final articles = <Article>[];

    data.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        articles.add(
          Article(
            title: value['title'] ?? 'Untitled',
            imageURL: value['thumbnail'] ?? '',
            contents: List<String>.from(value['paragraphs'] ?? []),
            sources: value['sources'] is String
                ? [value['sources']]
                : List<String>.from(value['sources'] ?? []),
          ),
        );
      }
    });

    // Optional: sort by order
    articles.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    return articles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder<List<Article>>(
        future: _fetchArticles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading articles: ${snapshot.error}'));
          }

          final articles = snapshot.data ?? [];

          if (articles.isEmpty) {
            return const Center(child: Text('No articles found.'));
          }

      return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Mental Wellness Articles",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: articles.length,
                      itemBuilder: (context, index) => _buildArticleCard(context, articles[index]),
                    ),

                  ],
                ),
              ),
            ),
          );

        },
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, Article article) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        onTap: () => _showArticleDialog(context, article),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageURL.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  article.imageURL,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(article.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showArticleDialog(BuildContext context, Article article) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final width = MediaQuery.of(context).size.width * (isMobile ? 0.9 : 0.6);
    final height = MediaQuery.of(context).size.height * (isMobile ? 0.9 : 0.6);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Header with Close Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      article.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              // Article Content Scrollable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...article.contents.map(
                            (p) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            p,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (article.sources.isNotEmpty)
                        TextButton(
                          onPressed: () async {
                            final url = article.sources.first;
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            } else {
                              debugPrint("Could not launch $url");
                            }
                          },
                          child: const Text(
                            "View Source",
                            style: TextStyle(color: MyColors.color2),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class Article {
  final String title;
  final String imageURL;
  final List<String> contents;
  final List<String> sources;
  final int? order;

  Article({
    required this.title,
    required this.imageURL,
    required this.contents,
    required this.sources,
    this.order,
  });
}
