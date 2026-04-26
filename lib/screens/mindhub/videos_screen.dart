import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../utils/constants/colors.dart';
import '../../models/mindhub_models.dart';
import '../../providers/mindhub_provider.dart';
import '../../providers/user_tracking_provider.dart';
import 'package:provider/provider.dart';

class MindHubVideosScreen extends StatelessWidget {
  const MindHubVideosScreen({Key? key}) : super(key: key);

  void _showVideoDialog(BuildContext context, VideoItem video) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => VideoPlayerDialog(video: video),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mindHubProvider = Provider.of<MindHubProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mindHubProvider.videos.isEmpty && !mindHubProvider.isLoading) {
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
                              "Mental Wellness Videos",
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
                          itemCount: mindHubProvider.videos.length,
                          itemBuilder: (context, index) => _buildVideoCard(context, mindHubProvider.videos[index]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildVideoCard(BuildContext context, VideoItem video) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          Provider.of<UserTrackingProvider>(context, listen: false).startTracking('Videos', itemName: video.title);
          _showVideoDialog(context, video);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                video.thumbnail,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(Icons.error, color: Colors.red),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(video.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    video.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildInteractionButtons(context, video.id, true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionButtons(BuildContext context, String id, bool isVideo) {
    final provider = Provider.of<MindHubProvider>(context);
    final choice = provider.getUserChoice(id, isVideo);
    
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
}

class VideoPlayerDialog extends StatefulWidget {
  final VideoItem video;

  const VideoPlayerDialog({Key? key, required this.video}) : super(key: key);

  @override
  _VideoPlayerDialogState createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  late YoutubePlayerController _youtubeController;
  VideoPlayerController? _localController;
  late bool _isYouTube;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _isYouTube = widget.video.isYouTube;

    if (_isYouTube) {
      _youtubeController = YoutubePlayerController.fromVideoId(
        videoId: YoutubePlayerController.convertUrlToId(widget.video.videoUrl) ?? '',
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
        ),
      );
    } else {
      _localController = VideoPlayerController.network(widget.video.videoUrl);
      _localController!.initialize().then((_) => setState(() {})).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This video can't be played on your device")),
        );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_isYouTube) {
      _youtubeController.close();
    } else {
      _localController?.dispose();
    }
    super.dispose();
  }

  Widget _buildVideoPlayer() {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isYouTube) {
      return SizedBox(
        width: screenWidth,
        child: YoutubePlayer(controller: _youtubeController),
      );
    } else if (_localController != null && _localController!.value.isInitialized) {
      return SizedBox(
        width: screenWidth,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: VideoPlayer(_localController!),
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogWidth = screenWidth >= 900 ? 800.0 : screenWidth * 0.95;
    final videoHeight = dialogWidth * 9 / 16;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: screenHeight * 0.9,
        ),
        child: RawScrollbar(
          controller: _scrollController,
          thumbColor: MyColors.color2,
          radius: const Radius.circular(8),
          thickness: 10,
          trackVisibility: true,
          thumbVisibility: true,
          interactive: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 800 ? 40 : 10,
                vertical: 10,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black, size: 24),
                      onPressed: () {
                        final choice = Provider.of<MindHubProvider>(context, listen: false).getUserChoice(widget.video.id, true);
                        if (choice == null) {
                          _showFeedbackPrompt(context, widget.video.id, true);
                        } else {
                          Provider.of<UserTrackingProvider>(context, listen: false).stopTracking(context);
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    width: dialogWidth,
                    height: videoHeight,
                    child: _buildVideoPlayer(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.video.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.video.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
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
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text("Close anyway", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: MyColors.color2),
            onPressed: () {
              final provider = Provider.of<MindHubProvider>(context, listen: false);
              if (provider.getUserChoice(id, isVideo) != null) {
                Provider.of<UserTrackingProvider>(context, listen: false).stopTracking(context);
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              } else {
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

  Widget _buildInteractionButtons(BuildContext context, String id, bool isVideo) {
    final provider = Provider.of<MindHubProvider>(context);
    final choice = provider.getUserChoice(id, isVideo);
    
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
}