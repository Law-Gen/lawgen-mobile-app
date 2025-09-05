import 'dart:async';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';

/// Contract for Server-Sent Events (SSE) based AI response streaming using
/// the `flutter_client_sse` package.
///
/// Typical flow:
/// 1. call [startResponseStream] with request metadata (e.g. conversation / question).
/// 2. listen to [responseStream] for incremental tokens / chunks.
/// 3. optionally call [cancelCurrentStream] to abort.
/// 4. call [dispose] on shutdown.
abstract class ChatSocketDataSource {
  /// Open an SSE connection for a new AI response.
  /// Any existing active stream should be cancelled first.
  Future<void> startResponseStream({
    required String conversationId,
    required String prompt,
    required String language,
    Map<String, String>? extraHeaders,
    Duration? connectTimeout,
  });

  /// Stream of raw textual chunks (already decoded) coming from the SSE server.
  /// Implementations should strip protocol framing and only emit the payload text.
  Stream<String> responseStream();

  /// Send a follow-up user message over a non-streaming channel if required by backend.
  /// (Some SSE backends require an HTTP POST instead; implement as no-op if unused.)
  Future<void> sendUserMessage({
    required String conversationId,
    required String message,
    String? language,
  });

  /// Cancel the currently active SSE stream (closes underlying connection).
  Future<void> cancelCurrentStream();

  /// Release resources.
  Future<void> dispose();
}

class ChatSocketDataSourceImpl implements ChatSocketDataSource {
  final StreamController<String> _responseController =
      StreamController.broadcast();
  StreamSubscription? _sseSubscription;

  // Replace with your actual SSE endpoint
  final String _baseUrl = "https://your-sse-endpoint.com/stream";

  @override
  Future<void> startResponseStream({
    required String conversationId,
    required String prompt,
    required String language,
    Map<String, String>? extraHeaders,
    Duration? connectTimeout,
  }) async {
    await cancelCurrentStream();

    // Construct the URL with query parameters
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'prompt': prompt,
      'language': language,
      if (conversationId.isNotEmpty) 'sessionId': conversationId,
    });

    _sseSubscription = SSEClient.subscribeToSSE(
      method: SSERequestType.GET,
      url: uri.toString(),
      header: extraHeaders ??
          {
            "Accept": "text/event-stream",
            "Cache-Control": "no-cache",
          },
    ).listen(
      (event) {
        if (event.data != null) {
          _responseController.add(event.data!);
        }
      },
      onError: (error) {
        _responseController.addError(error);
      },
      onDone: () {
        _responseController.close();
      },
    );
  }

  @override
  Stream<String> responseStream() {
    return _responseController.stream;
  }

  @override
  Future<void> sendUserMessage({
    required String conversationId,
    required String message,
    String? language,
  }) async {
    // This implementation assumes the SSE endpoint handles the conversation flow.
    // If your backend requires a separate POST request for follow-up messages,
    // you would implement that logic here using an HTTP client like Dio or http.
    // For this example, it's a no-op as the stream is managed by `startResponseStream`.
  }

  @override
  Future<void> cancelCurrentStream() async {
    await _sseSubscription?.cancel();
    _sseSubscription = null;
  }

  @override
  Future<void> dispose() async {
    await cancelCurrentStream();
    await _responseController.close();
  }
}

/* How to Use This Implementation

1.  **Replace the Placeholder URL**: Make sure to replace `"https://your-sse-endpoint.com/stream"` with the actual URL of your Server-Sent Events endpoint.
2.  **Handle Conversation IDs**:
    *   For the **first question** in a conversation, you can pass an empty string or a newly generated unique ID for `conversationId`.
    *   For **follow-up questions**, pass the `sessionId` you receive from your backend.
3.  **Error Handling**: The `responseStream` will now propagate any errors from the SSE connection, which you should handle in your UI or business logic.

This revised implementation should fit nicely into your existing chat repository structure and provide the unified streaming response you're looking for.*/