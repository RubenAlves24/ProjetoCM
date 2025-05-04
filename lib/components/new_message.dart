import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:harvestly/core/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/chat/chat_list_notifier.dart';

class NewMessage extends StatefulWidget {
  final String chatId;

  const NewMessage(this.chatId, {super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  String _message = '';
  final _messageController = TextEditingController();

  Future<void> _sendMessage() async {
    final user = AuthService().currentUser;

    if (user != null) {
      final msg = await ChatService().save(_message, user, widget.chatId);
      Provider.of<ChatListNotifier>(
        context,
        listen: false,
      ).updateLastMessage(widget.chatId, msg!);
      ;
      _messageController.clear();
      setState(() {
        _message = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _messageController,
            onChanged: (msg) => setState(() => _message = msg),
            decoration: InputDecoration(labelText: 'Escrever uma mensagem...'),
            onSubmitted: (_) {
              if (_message.trim().isNotEmpty) {
                _sendMessage();
              }
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: _message.trim().isEmpty ? null : _sendMessage,
        ),
      ],
    );
  }
}
