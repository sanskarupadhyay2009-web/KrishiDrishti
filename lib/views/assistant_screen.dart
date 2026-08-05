// lib/views/assistant_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../providers/assistant_provider.dart';
import '../providers/language_provider.dart';
import '../providers/sensor_provider.dart';
import '../services/voice_service.dart';
import '../utils/app_strings.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LanguageProvider>().strings;
    final assistantProvider = context.watch<AssistantProvider>();
    final sensorProvider = context.watch<SensorProvider>();
    final voiceService = context.read<VoiceService>();
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(strings.assistant)),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assistantProvider.messages.length,
              itemBuilder: (context, index) {
                final message = assistantProvider.messages[index];
                return _buildChatBubble(message, strings, voiceService, languageProvider.ttsLanguageCode);
              },
            ),
          ),
          if (assistantProvider.isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                const SizedBox(width: 12),
                Text(strings.waitForResponse),
              ]),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: strings.chatHint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  final text = _controller.text.trim();
                  if (text.isEmpty) return;
                  await assistantProvider.sendMessage(
                    text,
                    sensorProvider.currentData,
                    {'temp': 30.2, 'description': 'Partly Cloudy', 'rain_prob': '20%'},
                    languageProvider.languageCode,
                  );
                  _controller.clear();
                },
              ),
              IconButton(
                icon: const Icon(Icons.mic),
                onPressed: () async {
                  await voiceService.listen(languageProvider.speechLocaleCode, (result) {
                    setState(() {
                      _controller.text = result;
                    });
                  });
                },
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message, AppStrings strings, VoiceService voiceService, String ttsLanguage) {
    final alignment = message.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isUser ? Colors.green.shade100 : Colors.grey.shade200;
    final textColor = message.isUser ? Colors.black87 : Colors.black87;
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Flexible(child: Text(message.content, style: TextStyle(color: textColor, height: 1.4))),
          if (!message.isUser)
            IconButton(
              icon: const Icon(Icons.volume_up, size: 20),
              onPressed: () => voiceService.speak(message.content, ttsLanguage),
            ),
        ]),
      ),
    );
  }
}
