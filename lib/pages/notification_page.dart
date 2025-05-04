import 'package:provider/provider.dart' show Provider;

import '../core/notification/chat_notification_service.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<ChatNotificationService>(context);
    final items = service.items;
    return Scaffold(
      appBar: AppBar(title: Text("Notificações")),
      body:
          items.length == 0
              ? Center(child: Text("Sem notificações!"))
              : ListView.builder(
                itemCount: items.length,
                itemBuilder:
                    (ctx, i) => ListTile(
                      title: Text(items[i].title),
                      subtitle: Text(items[i].body),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check),
                            color: Colors.green,
                            onPressed: () {
                              // Ação para aceitar a notificação
                              // service.accept(i);
                              print("Entrou no grupo com sucesso!");
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.close),
                            color: Colors.red,
                            onPressed: () {
                              // Ação para recusar a notificação
                              print("Pedido recusado!");
                              service.remove(i);
                            },
                          ),
                        ],
                      ),
                      onTap: () => service.remove(i),
                    ),
              ),
    );
  }
}
