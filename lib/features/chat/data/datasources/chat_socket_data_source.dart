import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Session ID received event from backend
class SessionIdReceived {
  final String sessionId;
  const SessionIdReceived(this.sessionId);
}

/// Chat response chunk with text and optional sources
class MessageChunk {
  final String text;
  final List<Map<String, dynamic>>? sources;
  const MessageChunk({required this.text, this.sources});
}

/// Stream completion event with optional final text and suggested questions
class StreamCompleted {
  final String? finalText;
  final List<String>? suggestedQuestions;
  const StreamCompleted({this.finalText, this.suggestedQuestions});
}

/// Error event from the stream
class StreamError {
  final String message;
  const StreamError(this.message);
}

/// Union type for all possible SSE events
class ChatEvent {
  final SessionIdReceived? sessionIdReceived;
  final MessageChunk? messageChunk;
  final StreamCompleted? streamCompleted;
  final StreamError? streamError;

  ChatEvent.sessionId(String sessionId)
    : sessionIdReceived = SessionIdReceived(sessionId),
      messageChunk = null,
      streamCompleted = null,
      streamError = null;

  ChatEvent.message({required String text, List<Map<String, dynamic>>? sources})
    : sessionIdReceived = null,
      messageChunk = MessageChunk(text: text, sources: sources),
      streamCompleted = null,
      streamError = null;

  ChatEvent.completed({String? finalText, List<String>? suggestedQuestions})
    : sessionIdReceived = null,
      messageChunk = null,
      streamCompleted = StreamCompleted(
        finalText: finalText,
        suggestedQuestions: suggestedQuestions,
      ),
      streamError = null;

  ChatEvent.error(String message)
    : sessionIdReceived = null,
      messageChunk = null,
      streamCompleted = null,
      streamError = StreamError(message);
}

/// Contract for Server-Sent Events (SSE) based AI response streaming with session management
///
/// Typical flow:
/// 1. call [startResponseStream] with prompt (no session ID for first request)
/// 2. listen to the returned [Stream<ChatEvent>] for events
/// 3. capture session ID from SessionIdReceived event
/// 4. use session ID for follow-up requests with [startFollowUpStream]
/// 5. optionally call [cancelCurrentStream] to abort
/// 6. call [dispose] on shutdown
abstract class ChatSocketDataSource {
  /// Start a new conversation stream (without session ID)
  /// Returns a stream of ChatEvent objects including session ID
  Stream<ChatEvent> startResponseStream({
    required String prompt,
    required String language,
    Map<String, String>? extraHeaders,
    Duration? connectTimeout,
  });

  /// Continue an existing conversation stream (with session ID)
  /// Returns a stream of ChatEvent objects
  Stream<ChatEvent> startFollowUpStream({
    required String sessionId,
    required String prompt,
    required String language,
    Map<String, String>? extraHeaders,
    Duration? connectTimeout,
  });

  /// Cancel the currently active SSE stream (closes underlying connection).
  Future<void> cancelCurrentStream();

  /// Release resources.
  Future<void> dispose();
}

class ChatSocketDataSourceImpl implements ChatSocketDataSource {
  final http.Client client;
  final int maxRetries;
  final Duration initialBackoff;
  final double backoffMultiplier;

  StreamSubscription? _sseSubscription;
  StreamController<ChatEvent>? _responseController;
  bool _manuallyCancelled = false;
  // API endpoint URL
  static const String DEFAULT_QUERY_URL =
      'https://lawgen-backend-3ln1.onrender.com/api/v1/chats/query';

  ChatSocketDataSourceImpl({
    required this.client,

    this.maxRetries = 3,
    Duration? initialBackoff,
    this.backoffMultiplier = 2.0,
  }) : initialBackoff = initialBackoff ?? const Duration(seconds: 2);

  @override
  Stream<ChatEvent> startResponseStream({
    required String prompt,
    required String language,
    Map<String, String>? extraHeaders,
    Duration? connectTimeout,
  }) {
    return _startStream(
      prompt: prompt,
      language: language,
      sessionId: null, // No session ID for first request
      extraHeaders: extraHeaders,
      connectTimeout: connectTimeout,
    );
  }

  @override
  Stream<ChatEvent> startFollowUpStream({
    required String sessionId,
    required String prompt,
    required String language,
    Map<String, String>? extraHeaders,
    Duration? connectTimeout,
  }) {
    return _startStream(
      prompt: prompt,
      language: language,
      sessionId: sessionId, // Include session ID for follow-up
      extraHeaders: extraHeaders,
      connectTimeout: connectTimeout,
    );
  }

  Stream<ChatEvent> _startStream({
    required String prompt,
    required String language,
    String? sessionId,
    Map<String, String>? extraHeaders,
    Duration? connectTimeout,
  }) {
    debugPrint(
      'ChatSocketDataSource: Starting stream for prompt (${prompt.length} chars), sessionId=$sessionId, language=$language',
    );

    // Cancel any existing stream
    cancelCurrentStream();
    _manuallyCancelled = false;
    _responseController = StreamController<ChatEvent>();

    _connectToStream(
      prompt: prompt,
      language: language,
      sessionId: sessionId,
      extraHeaders: extraHeaders,
      connectTimeout: connectTimeout,
    );

    return _responseController!.stream;
  }

  Future<void> _connectToStream({
    required String prompt,
    required String language,
    String? sessionId = null,
    Map<String, String>? extraHeaders,
    Duration? connectTimeout,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
      'Cache-Control': 'no-cache',
      // 'Connection': 'keep-alive',
      ...?extraHeaders,
    };

    int attempts = 0;
    Duration backoff = initialBackoff;
    final timeout = connectTimeout ?? const Duration(seconds: 30);

    void connect() async {
      if (_manuallyCancelled) return;

      attempts++;
      debugPrint(
        'ChatSocketDataSource: Connecting to $DEFAULT_QUERY_URL (attempt $attempts)',
      );

      Timer? timeoutTimer;
      String sseBuffer = '';

      void cleanup() {
        timeoutTimer?.cancel();
        if (!(_responseController?.isClosed ?? true)) {
          _responseController?.close();
        }
      }

      void handleSSEEvent(String eventType, String data) {
        try {
          switch (eventType) {
            case 'session_id':
              final payload = jsonDecode(data) as Map<String, dynamic>;
              print(payload);
              final sessionId = payload['id']?.toString();
              print(sessionId);
              if (sessionId != null && sessionId.isNotEmpty) {
                _responseController?.add(ChatEvent.sessionId(sessionId));
              }
              break;

            case 'message':
              final payload = jsonDecode(data) as Map<String, dynamic>;
              print(payload);
              final text = payload['text']?.toString() ?? '';
              print(text);
              final sourcesData = payload['sources'] as List?;
              final sources = sourcesData
                  ?.map((s) => s as Map<String, dynamic>)
                  .toList();
              print(sources);
              if (text.isNotEmpty || (sources?.isNotEmpty ?? false)) {
                _responseController?.add(
                  ChatEvent.message(text: text, sources: sources),
                );
              }
              break;

            case 'complete':
              final payload = jsonDecode(data) as Map<String, dynamic>;
              final finalText = payload['is_complete']?.toString();
              print(finalText);
              _responseController?.add(
                ChatEvent.completed(finalText: finalText),
              );

              // Stream is complete, clean up
              cleanup();
              break;

            case 'error':
              final payload = jsonDecode(data) as Map<String, dynamic>;
              final message = payload['message']?.toString() ?? data;
              _responseController?.add(ChatEvent.error(message));
              cleanup();
              break;

            default:
              debugPrint(
                'ChatSocketDataSource: Unknown event type: $eventType',
              );
          }
        } catch (error) {
          debugPrint(
            'ChatSocketDataSource: Error processing event $eventType: $error',
          );
          _responseController?.add(
            ChatEvent.error('Failed to process server event: $error'),
          );
        }
      }

      void parseSSEEvent(String rawEvent) {
        String? eventType;
        String data = '';

        // Parse SSE format: event: type\ndata: payload
        for (String line in rawEvent.split('\n')) {
          if (line.startsWith('event: ')) {
            eventType = line.substring(7).trim();
          } else if (line.startsWith('data: ')) {
            if (data.isNotEmpty) data += '\n';
            data += line.substring(6).trim();
          }
        }

        if (eventType == null || data.isEmpty) return;

        debugPrint(
          'ChatSocketDataSource: Received event: $eventType, data: ${data.length} chars',
        );
        handleSSEEvent(eventType, data);
      }

      void processSSEBuffer() {
        // Process complete SSE events (separated by \n\n)
        List<String> events = sseBuffer.split('\n\n');

        // Keep the last incomplete event in buffer
        if (events.isNotEmpty && !sseBuffer.endsWith('\n\n')) {
          sseBuffer = events.removeLast();
        } else {
          sseBuffer = '';
        }

        for (String rawEvent in events) {
          if (rawEvent.trim().isEmpty) continue;
          parseSSEEvent(rawEvent.trim());
        }
      }

      Future<void> handleStreamError(dynamic error) async {
        timeoutTimer?.cancel();

        if (_manuallyCancelled) return;

        debugPrint(
          'ChatSocketDataSource: Stream error (attempt $attempts): $error',
        );

        await _sseSubscription?.cancel();
        _sseSubscription = null;

        if (attempts <= maxRetries) {
          final delay = Duration(
            milliseconds:
                (backoff.inMilliseconds *
                        (attempts > 1 ? backoffMultiplier : 1))
                    .round(),
          );

          debugPrint(
            'ChatSocketDataSource: Retrying in ${delay.inMilliseconds}ms...',
          );

          Timer(delay, () {
            if (!_manuallyCancelled) {
              backoff = Duration(
                milliseconds: (backoff.inMilliseconds * backoffMultiplier)
                    .round(),
              );
              connect();
            }
          });
        } else {
          debugPrint('ChatSocketDataSource: Max retries exceeded, failing');
          _responseController?.add(
            ChatEvent.error(
              'Connection failed after $maxRetries attempts: $error',
            ),
          );
          cleanup();
        }
      }

      // Build request body exactly as Go backend expects
      final requestBody = <String, dynamic>{
        'query': prompt,
        'language': language,
      };

      // Only include sessionId if provided (for follow-ups)
      if (sessionId != null && sessionId.isNotEmpty) {
        requestBody['sessionId'] = sessionId;
      }

      // Start timeout
      timeoutTimer = Timer(timeout, () {
        if (!_manuallyCancelled) {
          debugPrint(
            'ChatSocketDataSource: Request timeout after ${timeout.inSeconds}s',
          );
          _responseController?.add(
            ChatEvent.error('Request timeout after ${timeout.inSeconds}s'),
          );
          cleanup();
        }
      });

      try {
        final request = http.Request('POST', Uri.parse(DEFAULT_QUERY_URL))
          ..headers.addAll(headers)
          ..body = jsonEncode(requestBody);

        debugPrint('ChatSocketDataSource: Request body: ${request.body}');

        final streamedResponse = await client.send(request);

        if (streamedResponse.statusCode != 200) {
          throw Exception(
            'HTTP ${streamedResponse.statusCode}: ${streamedResponse.reasonPhrase}',
          );
        }

        timeoutTimer.cancel();
        debugPrint(
          'ChatSocketDataSource: Connected successfully, status: ${streamedResponse.statusCode}',
        );

        // Process SSE stream
        _sseSubscription = streamedResponse.stream
            .transform(const Utf8Decoder())
            .listen(
              (chunk) {
                if (_manuallyCancelled) return;

                sseBuffer += chunk;
                processSSEBuffer();
              },
              onError: (error) => handleStreamError(error),
              onDone: () {
                debugPrint('ChatSocketDataSource: Stream completed');
                cleanup();
              },
              cancelOnError: false,
            );
      } catch (error) {
        timeoutTimer.cancel();
        await handleStreamError(error);
      }
    }

    connect();
  }

  @override
  Future<void> cancelCurrentStream() async {
    if (_sseSubscription != null) {
      debugPrint('Cancelling SSE subscription');
      _manuallyCancelled = true;
      await _sseSubscription?.cancel();
      _sseSubscription = null;
      if (!(_responseController?.isClosed ?? true)) {
        await _responseController?.close();
      }
      _responseController = null;
      debugPrint('SSE subscription cancelled');
    } else {
      debugPrint('cancelCurrentStream called but no active subscription');
    }
  }

  @override
  Future<void> dispose() async {
    debugPrint('Disposing ChatSocketDataSourceImpl');
    await cancelCurrentStream();
    debugPrint('Disposed ChatSocketDataSourceImpl');
  }
}

/// Base URLs for API endpoints
class ChatApiEndpoints {
  /// URL for initial chat queries
  static const String queryUrl =
      'https://lawgen-backend-3ln1.onrender.com/api/v1/chats/query';

  /// URL for follow-up chat queries
  static const String followUpUrl =
      'https://lawgen-backend-3ln1.onrender.com/api/v1/chats/followup';

  /// Get the appropriate URL based on whether it's a follow-up or not
  static String getUrl({required bool isFollowUp}) =>
      isFollowUp ? followUpUrl : queryUrl;
}
