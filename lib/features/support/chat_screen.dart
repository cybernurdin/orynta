import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/icon_circle.dart';
import '../../data/models/chat_message.dart';
import '../../data/services/app_repository.dart';

/// Direct chat with an Agricultural Officer — the human-in-the-loop
/// channel FR-2.3 escalation cases route into (Orynta_SRS.md §3.2).
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(AppRepository repo) async {
    final body = _controller.text.trim();
    if (body.isEmpty || _sending) return;
    _controller.clear();
    setState(() => _sending = true);
    await repo.sendChatMessage(body);
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<LocaleProvider>().strings;
    final repo = context.watch<AppRepository>();
    final messages = repo.chatMessages;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const IconCircle(icon: Icons.support_agent_rounded, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings('supportChat'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(strings('agriculturalOfficer'), style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                ],
              ),
            ),
          ],
        ),
        titleSpacing: 8,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (_, i) => _ChatBubble(message: messages[i]),
            ),
          ),
          if (_sending)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                '…',
                style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(hintText: strings('typeMessage')),
                      onSubmitted: (_) => _send(repo),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.send_rounded),
                    onPressed: () => _send(repo),
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

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isFarmer = message.sender == ChatSender.farmer;
    return Align(
      alignment: isFarmer ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isFarmer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 3),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isFarmer ? AppColors.forest : AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.body,
              style: TextStyle(
                color: isFarmer ? AppColors.white : AppColors.ink,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '${message.sentAt.hour.toString().padLeft(2, '0')}:${message.sentAt.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 10, color: AppColors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
