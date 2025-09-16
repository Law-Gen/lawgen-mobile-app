import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../chat_dependency.dart';
import '../bloc/chat_bloc.dart';
import '../utils/design_constants.dart';
import '../widgets/message_bubble.dart';

// Helper class to adapt our byte stream for the just_audio player
class _StreamAudioSource extends StreamAudioSource {
  final Stream<List<int>> _stream;
  _StreamAudioSource(this._stream) : super(tag: 'voice-response');

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    return StreamAudioResponse(
      sourceLength: null, // We don't know the length of a live stream
      contentLength: null,
      offset: 0,
      stream: _stream,
      contentType: 'audio/mpeg',
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => chatsl<ChatBloc>()..add(LoadChatHistory()),
      child: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Chat',
          style: TextStyle(
            color: kPrimaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kBackgroundColor,
        elevation: 1,
        shadowColor: kShadowColor,
        actions: [
          BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ChatSessionLoaded) {
                return IconButton(
                  icon: const Icon(Icons.history, color: kPrimaryTextColor),
                  onPressed: () =>
                      context.read<ChatBloc>().add(LoadChatHistory()),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatHistoryLoaded) {
            return FloatingActionButton(
              onPressed: () => context.read<ChatBloc>().add(StartNewChat()),
              backgroundColor: kButtonColor,
              child: const Icon(Icons.add, color: Colors.white),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading || state is ChatInitial) {
            return const Center(
              child: CircularProgressIndicator(color: kButtonColor),
            );
          }
          if (state is ChatHistoryLoaded) {
            return ChatHistoryView(state: state);
          }
          if (state is ChatSessionLoaded) {
            return ChatView(state: state);
          }
          if (state is ChatError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Welcome!'));
        },
      ),
    );
  }
}

class ChatHistoryView extends StatelessWidget {
  final ChatHistoryLoaded state;
  const ChatHistoryView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.sessions.sessions.isEmpty) {
      return const Center(
        child: Text(
          "No past conversations.\nTap '+' to start a new one!",
          textAlign: TextAlign.center,
          style: TextStyle(color: kSecondaryTextColor, fontSize: 16),
        ),
      );
    }
    return ListView.builder(
      itemCount: state.sessions.sessions.length,
      itemBuilder: (context, index) {
        final session = state.sessions.sessions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: kCardBackgroundColor,
          elevation: 2,
          shadowColor: kShadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              session.title,
              style: const TextStyle(
                color: kPrimaryTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Last active: ${session.lastActiveAt.toLocal()}',
              style: const TextStyle(color: kSecondaryTextColor),
            ),
            onTap: () {
              context.read<ChatBloc>().add(LoadChatSession(session.id));
            },
          ),
        );
      },
    );
  }
}

class ChatView extends StatefulWidget {
  final ChatSessionLoaded state;
  const ChatView({super.key, required this.state});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterSoundRecorder _audioRecorder = FlutterSoundRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecorderInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _audioRecorder.openRecorder();
    setState(() {
      _isRecorderInitialized = true;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _audioRecorder.closeRecorder();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleVoiceCommand() async {
    if (!_isRecorderInitialized) return;
    final bloc = context.read<ChatBloc>();

    if (_audioRecorder.isRecording) {
      final path = await _audioRecorder.stopRecorder();
      if (path != null) {
        bloc.add(SendVoiceMessage(audioFile: File(path), language: 'en'));
      }
    } else {
      if (await Permission.microphone.request().isGranted) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/flutter_sound.wav';
        await _audioRecorder.startRecorder(toFile: path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required.')),
        );
      }
    }
    setState(() {});
  }

  Future<void> _playAudioStream(Stream<List<int>> stream) async {
    print("UI received audio stream. Attempting to save it for debugging...");
    try {
      // --- START OF DEBUGGING CODE ---

      // Get a temporary directory to save the file
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/debug_audio_response.bin'; // Save as a generic binary file
      final file = File(filePath);
      final sink = file.openWrite();

      // Listen to the stream and write all the bytes to the file
      await stream.forEach((bytes) {
        sink.add(bytes);
      });

      // Close the file sink
      await sink.close();

      final fileLength = await file.length();
      print("SUCCESS: Saved stream to file at: $filePath");
      print("File size: $fileLength bytes.");

      // --- END OF DEBUGGING CODE ---

      // We will now try to play from the file we just saved
      if (fileLength > 0) {
        print("Attempting to play the saved file...");
        await _audioPlayer.setFilePath(filePath);
        _audioPlayer.play();
        await _audioPlayer.playerStateStream.firstWhere(
          (s) => s.processingState == ProcessingState.completed,
        );
      } else {
        print("Skipping playback because the received stream was empty.");
      }
    } catch (e) {
      print("Error during stream processing/playback: $e");
    } finally {
      // Tell the BLoC to clear the audio stream from the state
      context.read<ChatBloc>().add(AudioPlaybackFinished());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatSessionLoaded) {
          _scrollToBottom();
          if (state.audioStreamToPlay != null) {
            _playAudioStream(state.audioStreamToPlay!);
          }
        }
      },
      child: Column(
        children: [
          Expanded(
            child: widget.state.messages.isEmpty
                ? const Center(
                    child: Text(
                      'Send a message to start!',
                      style: TextStyle(color: kSecondaryTextColor),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: widget.state.messages.length,
                    itemBuilder: (context, index) {
                      final message = widget.state.messages[index];
                      return MessageBubble(
                        content: message.content,
                        isUserMessage: message.type == 'user_query',
                      );
                    },
                  ),
          ),
          _buildTextInput(),
        ],
      ),
    );
  }

  Widget _buildTextInput() {
    final isRecording = _audioRecorder.isRecording;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: kBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4,
            color: kShadowColor.withOpacity(0.5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: kPrimaryTextColor),
                decoration: const InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: kSecondaryTextColor),
                  filled: true,
                  fillColor: kCardBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: isRecording ? Colors.red.shade400 : kSecondaryTextColor,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: _isRecorderInitialized ? _handleVoiceCommand : null,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Icon(
                    isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: kButtonColor,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: _sendMessage,
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(Icons.send, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatBloc>().add(
        SendTextMessage(query: text, language: 'en'),
      );
      _textController.clear();
    }
  }
}
