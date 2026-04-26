class Article {
  final String id;
  final String title;
  final String imageURL;
  final List<String> contents;
  final List<String> sources;
  final int order;
  final Map<String, int> interactions;

  Article({
    required this.id,
    required this.title,
    required this.imageURL,
    required this.contents,
    required this.sources,
    this.order = 0,
    this.interactions = const {'insightful': 0, 'helpful': 0, 'cannot_relate': 0},
  });

  factory Article.fromMap(String id, Map<String, dynamic> map) {
    final inter = map['interactions'] as Map<String, dynamic>? ?? {};
    return Article(
      id: id,
      title: map['title'] ?? 'Untitled',
      imageURL: map['thumbnail'] ?? '',
      contents: List<String>.from(map['paragraphs'] ?? []),
      sources: map['sources'] is String
          ? [map['sources']]
          : List<String>.from(map['sources'] ?? []),
      order: map['order'] ?? 0,
      interactions: {
        'insightful': inter['insightful'] ?? 0,
        'helpful': inter['helpful'] ?? 0,
        'cannot_relate': inter['cannot_relate'] ?? 0,
      },
    );
  }
}

class VideoItem {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final String videoUrl;
  final bool isYouTube;
  final int order;
  final Map<String, int> interactions;

  const VideoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.videoUrl,
    required this.isYouTube,
    required this.order,
    this.interactions = const {'insightful': 0, 'helpful': 0, 'cannot_relate': 0},
  });

  factory VideoItem.fromMap(String id, Map<String, dynamic> map) {
    final inter = map['interactions'] as Map<String, dynamic>? ?? {};
    final url = map['videoUrl'] ?? '';
    return VideoItem(
      id: id,
      title: map['title'] ?? 'Untitled',
      description: map['description'] ?? 'No description',
      thumbnail: map['thumbnail'] ?? '',
      videoUrl: url,
      isYouTube: url.contains('youtube.com') || url.contains('youtu.be'),
      order: map['order'] ?? 0,
      interactions: {
        'insightful': inter['insightful'] ?? 0,
        'helpful': inter['helpful'] ?? 0,
        'cannot_relate': inter['cannot_relate'] ?? 0,
      },
    );
  }
}
