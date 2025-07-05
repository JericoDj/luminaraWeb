class VideoItem {
  final String title;
  final String description;
  final String thumbnail;
  final String videoUrl;
  final bool isYouTube;

  VideoItem({
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.videoUrl,
    required this.isYouTube,
  });

  static bool isYouTubeUrl(String url) {
    return url.contains('youtube.com') || url.contains('youtu.be');
  }
}