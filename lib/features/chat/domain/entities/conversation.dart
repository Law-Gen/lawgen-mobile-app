import 'message.dart';

class Conversation {
  final String id;
  final String title;
  final List<Message> messages;

  Conversation({
    required this.id,
    required this.title,
    required this.messages,
  });
}