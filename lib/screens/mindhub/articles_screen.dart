import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luminarawebsite/Footer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/constants/colors.dart';
import '../../utils/mindhub_rich_text.dart';
import '../../models/mindhub_models.dart';
import '../../providers/mindhub_provider.dart';
import '../../providers/user_tracking_provider.dart';
import 'package:provider/provider.dart';



class SafeSpaceHubArticles extends StatelessWidget {
  const SafeSpaceHubArticles({Key? key}) : super(key: key);

  // Removed _fetchArticles as it's now in the provider


  @override
  Widget build(BuildContext context) {
    final mindHubProvider = Provider.of<MindHubProvider>(context);
    
    // Auto-fetch if empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mindHubProvider.articles.isEmpty && !mindHubProvider.isLoading) {
        mindHubProvider.fetchData();
      }
    });

    return Scaffold(
      body: mindHubProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await mindHubProvider.fetchData(force: true);
                if (mindHubProvider.isRateLimited) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please wait 30 seconds before refreshing again.')),
                  );
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Mental Wellness Articles",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            if (mindHubProvider.isRateLimited)
                              const Text("Cooldown active...", style: TextStyle(color: Colors.red, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: mindHubProvider.articles.length,
                          itemBuilder: (context, index) => _buildArticleCard(context, mindHubProvider.articles[index]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );

  }

  Widget _buildArticleCard(BuildContext context, Article article) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Provider.of<UserTrackingProvider>(context, listen: false).startTracking('Articles', itemName: article.title);
          _showArticleDialog(context, article);
        },
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
              child: MindHubRichText(
                text: article.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildInteractionButtons(context, article.id, false),
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
                    child: MindHubRichText(
                      text: article.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),

                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      final choice = Provider.of<MindHubProvider>(context, listen: false).getUserChoice(article.id, false);
                      if (choice == null) {
                        _showFeedbackPrompt(context, article.id, false);
                      } else {
                        Provider.of<UserTrackingProvider>(context, listen: false).stopTracking(context);
                        Navigator.of(context).pop();
                      }
                    },
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
                          child: MindHubRichText(
                            text: p,
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

  Widget _buildInteractionButtons(BuildContext context, String id, bool isVideo) {
    final provider = Provider.of<MindHubProvider>(context);
    final choice = provider.getUserChoice(id, isVideo);
    
    // Find the item to get current counts
    final itemInteractions = isVideo 
        ? provider.videos.firstWhere((v) => v.id == id).interactions
        : provider.articles.firstWhere((a) => a.id == id).interactions;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildChoiceButton(context, 'insightful', Icons.lightbulb_outline, 'Insightful', itemInteractions['insightful']!, choice == 'insightful', id, isVideo),
        _buildChoiceButton(context, 'helpful', Icons.thumb_up_outlined, 'Helpful', itemInteractions['helpful']!, choice == 'helpful', id, isVideo),
        _buildChoiceButton(context, 'cannot_relate', Icons.sentiment_dissatisfied, 'Cannot Relate', itemInteractions['cannot_relate']!, choice == 'cannot_relate', id, isVideo),
      ],
    );
  }

  Widget _buildChoiceButton(BuildContext context, String key, IconData icon, String label, int count, bool isSelected, String id, bool isVideo) {
    final provider = Provider.of<MindHubProvider>(context, listen: false);
    return InkWell(
      onTap: () {
        provider.updateInteraction(id, key, isVideo);
        Provider.of<UserTrackingProvider>(context, listen: false).logEvent(context, isVideo ? 'Videos' : 'Articles', id, 'rate_$key');
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? MyColors.color2 : Colors.grey, size: 20),
          const SizedBox(height: 4),
          Text(
            '$label ($count)',
            style: TextStyle(
              color: isSelected ? MyColors.color2 : Colors.grey,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackPrompt(BuildContext context, String id, bool isVideo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("How did you find this?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please select an option below:"),
            const SizedBox(height: 20),
            _buildInteractionButtons(context, id, isVideo),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<UserTrackingProvider>(context, listen: false).stopTracking(context);
              Navigator.of(ctx).pop(); // Close prompt
              Navigator.of(context).pop(); // Close article
            },
            child: const Text("Close anyway", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: MyColors.color2),
            onPressed: () {
              final provider = Provider.of<MindHubProvider>(context, listen: false);
              if (provider.getUserChoice(id, isVideo) != null) {
                Provider.of<UserTrackingProvider>(context, listen: false).stopTracking(context);
                Navigator.of(ctx).pop(); // Close prompt
                Navigator.of(context).pop(); // Close article
              } else {
                // User hasn't picked yet
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select an option before continuing.')),
                );
              }
            },
            child: const Text("Done", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


// Removed old Article class as it's now imported from models/mindhub_models.dart

