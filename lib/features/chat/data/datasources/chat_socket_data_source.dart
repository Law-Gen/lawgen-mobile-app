import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';

/// Contract for Server-Sent Events (SSE) based AI response streaming using
/// the `flutter_client_sse` package.
///
/// Typical flow:
/// 1. call [startResponseStream] with request metadata (e.g. conversation / question).
/// 2. listen to the returned [Stream] for incremental tokens / chunks.
/// 3. optionally call [cancelCurrentStream] to abort.
/// 4. call [dispose] on shutdown.
abstract class ChatSocketDataSource {
  /// Open an SSE connection for a new AI response.
  /// Any existing active stream should be cancelled first.
  /// Returns a stream of raw textual chunks from the SSE server.
  Stream<String> startResponseStream({
    required String conversationId,
    required String prompt,
    required String language,
    Map<String, String>? extraHeaders,
    Duration? connectTimeout,
  });

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
  StreamSubscription? _sseSubscription;
  StreamController<String>? _responseController;
  bool _manuallyCancelled = false;
  // Configurable endpoint and retry policy
  final String baseUrl;
  final int maxRetries; // number of reconnection attempts after an error
  final Duration initialBackoff;
  final double backoffMultiplier;

  ChatSocketDataSourceImpl({
    String? baseUrl,
    this.maxRetries = 0,
    Duration? initialBackoff,
    this.backoffMultiplier = 2.0,
  }) : baseUrl = baseUrl ?? _platformDefaultUrl(),
       initialBackoff = initialBackoff ?? const Duration(seconds: 2);

  static String _platformDefaultUrl() {
    // On Android emulator, host machine's localhost is 10.0.2.2
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:5000/stream';
    }
    return 'http://127.0.0.1:5000/stream';
  }

  @override
  Stream<String> startResponseStream({
    required String conversationId,
    required String prompt,
    required String language,
    Map<String, String>? extraHeaders,
    Duration? connectTimeout,
  }) {
    debugPrint(
      'startResponseStream called: conversationId=$conversationId, prompt=${prompt.length} chars, language=$language, maxRetries=$maxRetries',
    );

    // Cancel any existing stream before starting a new one.
    cancelCurrentStream();
    _manuallyCancelled = false;
    _responseController = StreamController<String>();

    final headers =
        extraHeaders ??
        {'Accept': 'text/event-stream', 'Cache-Control': 'no-cache'};

    int attempts = 0;
    Duration backoff = initialBackoff;
    final Duration firstChunkTimeout =
        connectTimeout ?? const Duration(seconds: 40);
    Timer? firstChunkTimer;

    void scheduleFirstChunkTimer() {
      firstChunkTimer?.cancel();
      firstChunkTimer = Timer(firstChunkTimeout, () async {
        if (_manuallyCancelled) return;
        debugPrint(
          'SSE first-chunk timeout after ${firstChunkTimeout.inSeconds}s',
        );
        _responseController?.addError(
          TimeoutException(
            'SSE start timeout after ${firstChunkTimeout.inSeconds}s',
          ),
        );
        _manuallyCancelled = true;
        await _sseSubscription?.cancel();
        _sseSubscription = null;
        await _responseController?.close();
      });
    }

    void connect() {
      if (_manuallyCancelled) return;
      final uri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'prompt': prompt,
          'language': language,
          if (conversationId.isNotEmpty) 'sessionId': conversationId,
        },
      );

      debugPrint('Connecting to SSE: $uri (attempt ${attempts + 1})');
      debugPrint('SSE headers: $headers');

      scheduleFirstChunkTimer();

      _sseSubscription =
          SSEClient.subscribeToSSE(
            method: SSERequestType.GET,
            url: uri.toString(),
            header: headers,
          ).listen(
            (event) {
              // First chunk arrived; cancel the timeout
              firstChunkTimer?.cancel();
              firstChunkTimer = null;
              if (event.data != null) {
                final data = event.data!.trim();
                // Treat "[Done]" / "[DONE]" as an end-of-stream sentinel
                if (data.toLowerCase() == '[done]') {
                  debugPrint('SSE received [Done] sentinel; completing stream');
                  // Close our outward stream and cancel the SSE subscription
                  if (!(_responseController?.isClosed ?? true)) {
                    _responseController?.close();
                  }
                  _sseSubscription?.cancel();
                  _sseSubscription = null;
                  return;
                }
                _responseController?.add(data);
              }
            },
            onError: (error) async {
              // Cancel first-chunk timer on error
              firstChunkTimer?.cancel();
              firstChunkTimer = null;
              if (_manuallyCancelled) return;
              debugPrint('SSE error: $error');
              _responseController?.addError(error);
              await _sseSubscription?.cancel();
              _sseSubscription = null;
              if (attempts < maxRetries) {
                attempts += 1;
                final delay = backoff;
                backoff = Duration(
                  milliseconds: (backoff.inMilliseconds * backoffMultiplier)
                      .round(),
                );
                debugPrint(
                  'Retrying SSE in ${delay.inMilliseconds}ms (attempt $attempts/$maxRetries)',
                );
                Future.delayed(delay, () {
                  if (!_manuallyCancelled) connect();
                });
              } else {
                await _responseController?.close();
              }
            },
            onDone: () async {
              // Cancel first-chunk timer on stream completion
              firstChunkTimer?.cancel();
              firstChunkTimer = null;
              if (_manuallyCancelled) return;
              debugPrint('SSE stream done');
              await _responseController?.close();
            },
            cancelOnError: false,
          );
    }

    connect();
    return _responseController!.stream;
  }

  // This method is kept for completeness of the abstract class implementation.
  @override
  Future<void> sendUserMessage({
    required String conversationId,
    required String message,
    String? language,
  }) async {
    debugPrint(
      'sendUserMessage called: conversationId=$conversationId, message=${message.length} chars, language=$language',
    );
    // Implementation would go here if needed.
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
