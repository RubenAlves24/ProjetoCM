import 'dart:async';

import 'package:harvestly/components/messages.dart';
import 'package:harvestly/components/new_message.dart';
import 'package:harvestly/core/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/chat/chat_list_notifier.dart';
import '../utils/app_routes.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  StreamSubscription? _messageSubscription;

  @override
  void initState() {
    super.initState();
    final chatService = Provider.of<ChatService>(
      context,
      listen: false,
    );
    final currentChat = chatService.currentChat!;

    chatService.listenToCurrentChatMessages((messages) {
      if (messages.isNotEmpty) {
        final lastMessage = messages.first;
        final notifier = Provider.of<ChatListNotifier>(context, listen: false);
        notifier.updateLastMessage(currentChat.id!, lastMessage);
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  Widget getLeadingAppBarWidget(BuildContext context) {
    final currentChat = Provider.of<ChatService>(context).currentChat!;

    return InkWell(
      onTap: () async {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.MAIN_MENU, (route) => false);
      },
      borderRadius: BorderRadius.circular(100),
      child: Row(
        children: [
          const Icon(Icons.arrow_back),
          const SizedBox(width: 5),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: FutureBuilder(
              future: Future.value(currentChat.imageUrl),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Icon(Icons.group);
                }
                return CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(snapshot.data as String),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatService>(
      builder: (ctx, chatService, _) {
        final currentChat = chatService.currentChat!;
        return Scaffold(
          appBar: AppBar(
            leadingWidth: 70,
            leading: getLeadingAppBarWidget(context),
            title: Text(currentChat.name!),
            centerTitle: false,
            titleSpacing: 5,
            titleTextStyle: const TextStyle(fontSize: 22),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.CHAT_SETTINGS_PAGE);
                },
                icon: Icon(
                  Icons.settings,
                  color: Theme.of(context).primaryIconTheme.color,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(child: Messages(currentChat.id!)),
                NewMessage(currentChat.id!),
              ],
            ),
          ),
        );
      },
    );
  }
}
