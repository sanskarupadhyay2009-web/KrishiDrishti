import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'services/chat_assistant.dart';
import 'utils/app_strings.dart';

class _ChatMessage {
  final String text;
  final bool fromUser;
  _ChatMessage(this.text, this.fromUser);
}

/// Text-based AI chat assistant (Phase 5 concept), implemented for the MVP
/// as a fully offline keyword responder — see [ChatAssistant]. Works with
/// no internet connection and no API key, which matters a lot for farmers
/// in low-connectivity areas.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _greeted = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send(bool isHindi) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text, true));
      _messages.add(_ChatMessage(ChatAssistant.reply(text, isHindi), false));
    });
    _controller.clear();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final s = AppStrings(app.isHindi);

    if (!_greeted) {
      _greeted = true;
      _messages.add(_ChatMessage(s.chatGreeting, false));
    }

    return Scaffold(
      appBar: AppBar(title: Text(s.chatTitle)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: msg.fromUser ? const Color(0xFF2E7D32) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: msg.fromUser
                          ? null
                          : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Text(
                      msg.text,
                      style: TextStyle(
                        color: msg.fromUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(app.isHindi),
                      decoration: InputDecoration(
                        hintText: s.chatHint,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF2E7D32),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () => _send(app.isHindi),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
