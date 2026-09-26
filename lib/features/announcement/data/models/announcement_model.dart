class Announcement {
  final String title;
  final String content;

  Announcement({
    required this.title,
    required this.content,
  });

  factory Announcement.fromMap(Map<String, dynamic> data) {
    return Announcement(
      title: data['title'],
      content: data['content'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "content": content,
    };
  }
}
