import 'package:flutter/material.dart';
import '../components/chat_settings_form.dart';
import '../core/services/auth/auth_service.dart';
import '../core/services/chat/chat_service.dart';
import '../utils/app_routes.dart';

class ChatSettingsPage extends StatefulWidget {
  const ChatSettingsPage({super.key});

  @override
  State<ChatSettingsPage> createState() => _ChatSettingsPageState();
}

class _ChatSettingsPageState extends State<ChatSettingsPage> {
  bool _isAdmin = false;
  bool _isModerator = false;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    List<String>? adminIds = ChatService().currentChat!.adminIds;
    final userId = AuthService().currentUser!.id;
    if (adminIds == null || adminIds.isEmpty) {
      ChatService().makeUserAdmin(userId);
      adminIds = ChatService().currentChat!.adminIds;
      _isAdmin = true;
      _isModerator = true;
    } else {
      (adminIds.contains(userId)) ? _isAdmin = true : _isAdmin = false;
      (adminIds.first == userId) ? _isModerator = true : _isModerator = false;
    }
  }

  void _removeChat() {
    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setDialogState) => AlertDialog(
                  title: Text("Aviso"),
                  content: Text(
                    "Tem a certeza que pretende eliminar este grupo?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () async {
                        setDialogState(() => _isLoading = true);
                        try {
                          await ChatService().removeChat();

                          if (ctx.mounted) Navigator.of(ctx).pop();

                          if (mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.MAIN_MENU,
                              (route) => false,
                            );
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Erro ao remover o grupo."),
                              ),
                            );
                          }
                        }
                      },
                      child:
                          _isLoading
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Text("Confirmar"),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalhes do Grupo"),
        actions: [
          if (_isModerator)
            IconButton(
              onPressed: _removeChat,
              icon: Icon(Icons.delete, color: Colors.red),
            ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: ChatSettingsForm(isAdmin: _isAdmin),
        ),
      ),
    );
  }
}
