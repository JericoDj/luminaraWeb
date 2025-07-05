import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
class VideoItem {
  final String title;
  final String description;
  final String thumbnail;
  final String videoUrl;
  final bool isYouTube;
  final int order; // Add order field

  const VideoItem({
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.videoUrl,
    required this.isYouTube,
    required this.order,
  });

  factory VideoItem.fromMap(Map<String, dynamic> map) {
    return VideoItem(
      title: map['title'] ?? 'Untitled',
      description: map['description'] ?? 'No description',
      thumbnail: map['thumbnail'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      isYouTube: _isYouTubeUrl(map['videoUrl'] ?? ''),
      order: map['order'] ?? 0,
    );
  }

  static bool _isYouTubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }
}

class MindHubVideosScreen extends StatelessWidget {
  const MindHubVideosScreen({Key? key}) : super(key: key);

  Future<List<VideoItem>> _fetchVideosFromFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('contents')
          .doc('videos')
          .get();

      if (!doc.exists) return [];

      final data = doc.data()!;
      final List<VideoItem> videos = [];

      data.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          videos.add(VideoItem.fromMap(value));
        }
      });

      // Sort videos by order field
      videos.sort((a, b) => a.order.compareTo(b.order));
      return videos;
    } catch (e) {
      print('Error fetching videos: $e');
      return [];
    }
  }


  void _showVideoDialog(BuildContext context, VideoItem video) {
    showDialog(
      context: context,
      builder: (context) => VideoPlayerDialog(video: video),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder<List<VideoItem>>(
        future: _fetchVideosFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No videos found.'));
          }

          final videos = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: InkWell(
                  onTap: () => _showVideoDialog(context, video),
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                        child: Image.network(
                          video.thumbnail,

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
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(video.title,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              video.description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87),
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

  @override
  void initState() {
    super.initState();
    _isYouTube = widget.video.isYouTube;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (_isYouTube) {
      final videoId = YoutubePlayer.convertUrlToId(widget.video.videoUrl);
      if (videoId != null && videoId.isNotEmpty) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            enableCaption: true,
          ),
        );
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid YouTube video link.")),
          );
          Navigator.of(context).pop(); // Close dialog
        });
      }

    } else {
      _localController = VideoPlayerController.network(widget.video.videoUrl);
      _localController!
          .initialize()
          .then((_) => setState(() {}))
          .catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This video can't be played on your device")),
        );
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    if (_isYouTube) {
      _youtubeController.dispose();
    } else {
      _localController?.dispose();
    }
    super.dispose();
  }

  Widget _buildVideoPlayer(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Stack(
      children: [
        if (_isYouTube)
          YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: _youtubeController,
              aspectRatio: isLandscape ? 16 / 9 : 16 / 9,
            ),
            builder: (context, player) => player,
          )
        else if (_localController != null && _localController!.value.isInitialized)
          AspectRatio(
            aspectRatio: _localController!.value.aspectRatio,
            child: VideoPlayer(_localController!),
          )
        else
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(

              flex: 1,
              child: Stack(
                children: [
                  _buildVideoPlayer(context),
                  if (!isLandscape)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                ],
              ),
            ),
            if (!isLandscape)
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Padding(

                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(widget.video.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(widget.video.description, style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}