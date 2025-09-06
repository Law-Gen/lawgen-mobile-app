import '../../data/datasources/chat_socket_data_source.dart';

class AskResult {
  final String conversationId;
  final Stream<ChatEvent> stream;
  final String? sessionId; // Store the received session ID

  AskResult({
    required this.conversationId,
    required this.stream,
    this.sessionId,
  });

  // Create a copy with updated session ID
  AskResult copyWith({String? sessionId}) {
    return AskResult(
      conversationId: conversationId,
      stream: stream,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}
