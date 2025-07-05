class CarouselItemModel {
  final int order;
  final String title;
  final String url;

  CarouselItemModel({required this.order, required this.title, required this.url});

  factory CarouselItemModel.fromMap(Map<String, dynamic> data) {
    return CarouselItemModel(
      order: data['order'],
      title: data['title'],
      url: data['url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'order': order, 'title': title, 'url': url};
  }
}