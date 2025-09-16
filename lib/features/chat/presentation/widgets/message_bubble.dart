import 'package:flutter/material.dart';
import '../utils/design_constants.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isUserMessage;

  const MessageBubble({
    super.key,
    required this.content,
    required this.isUserMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isUserMessage ? kButtonColor : kCardBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isUserMessage
                ? const Radius.circular(20)
                : const Radius.circular(0),
            bottomRight: isUserMessage
                ? const Radius.circular(0)
                : const Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: kShadowColor.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isUserMessage ? Colors.white : kPrimaryTextColor,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
