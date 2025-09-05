class Message {
  final String role;
  final String content;
  final String? language;

  Message({
    required this.role,
    required this.content,
    this.language,
  });
}