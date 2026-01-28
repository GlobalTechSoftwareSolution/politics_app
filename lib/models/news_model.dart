class NewsModel {
  final String id;
  final String title;
  final String content;
  final String date;
  final String imageUrl;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.imageUrl,
  });

  // Factory method to create a NewsModel from JSON
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'].toString(),
      title: json['title'],
      content: json['content'],
      date: json['date'],
      imageUrl: json['imageUrl'],
    );
  }

  // Method to convert a NewsModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date,
      'imageUrl': imageUrl,
    };
  }
}
