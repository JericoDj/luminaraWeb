import 'package:flutter/material.dart';

class ChatController {
  final Function()? onChatStarted;
  final Function()? onChatEnded;

  ChatController({this.onChatStarted, this.onChatEnded});

  void initChat(String? roomId) {
    if (roomId != null && onChatStarted != null) {
      onChatStarted!();
      print("💬 Chat initialized with Room ID: $roomId");
    } else {
      print("❌ Error: Room ID is missing or `onChatStarted` callback is not set.");
    }
  }

  void endChat() {
    if (onChatEnded != null) {
      onChatEnded!();
      print("❌ Chat ended.");
    }
  }
}
