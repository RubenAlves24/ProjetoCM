import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../components/user_info_card.dart';
import '../core/notification/chat_notification_service.dart';
import '../core/services/auth/auth_service.dart';
import '../core/services/chat/chat_list_notifier.dart';
import '../utils/app_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditingName = false;
  bool _isEditingEmail = false;
  bool _isEditingPhone = false;
  bool _isLoading = false;
  bool _isButtonVisible = false;
  bool _isEditingBackgroundImage = false;
  bool _isEditingNickname = false;
  bool _isEditingAboutMe = false;

  File? _backgroundImage;
  File? _profileImage;

  String? _errorMessage;
  String? _currentPopUpTextMessage;
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _lastNameTextController = TextEditingController();
  final TextEditingController _customStatusController = TextEditingController();

  bool _isExpanded = false;
  String _selectedStatus =
      AuthService().currentUser?.status ?? "Clique para personalizar";
  IconData _selectedIcon = Icons.circle_outlined;
  Color _selectedColor = Colors.grey;
  IconData _selectedCustomIcon = Icons.sentiment_satisfied;
  String? _selectedCustomIconKey;
  String? _selectedIconKey;

  final List<Map<String, dynamic>> _statusOptions = [
    {
      "key": "check_circle",
      "text": "Disponível",
      "icon": Icons.check_circle,
      "color": Colors.green,
    },
    {
      "key": "dont_disturb",
      "text": "Ocupado",
      "icon": Icons.do_not_disturb,
      "color": Colors.red,
    },
    {
      "key": "absent",
      "text": "Ausente",
      "icon": Icons.access_time,
      "color": Colors.orange,
    },
    {
      "key": "offline",
      "text": "Offline",
      "icon": Icons.cloud_off,
      "color": Colors.grey,
    },
  ];

  final Map<String, IconData> _iconOptions = {
    "satisfied": Icons.sentiment_satisfied,
    "dissatisfied": Icons.sentiment_dissatisfied,
    "thumbs_up": Icons.thumb_up,
    "thumbs_down": Icons.thumb_down,
    "favorite": Icons.favorite,
    "star": Icons.star,
    "wifi_off": Icons.wifi_off,
  };

  void _initStatus() {
    final user = AuthService().currentUser!;
    if (user.status != null) {
      final storedStatus = user.status;
      final selectedList = _statusOptions.where(
        (s) => s["text"] == storedStatus,
      );
      final selected = (selectedList.isNotEmpty) ? selectedList.first : null;
      if (selected != null)
        setState(() {
          _selectedStatus = selected["text"];
          _selectedIcon = selected["icon"];
          _selectedColor = selected["color"];
        });
      else {
        setState(() {
          try {
            _selectedIcon =
                _iconOptions.entries
                    .firstWhere(
                      (entry) => entry.key == user.customIconStatus,
                      orElse: () => MapEntry("", Icons.error),
                    )
                    .value;
          } catch (e) {
            _selectedIcon = Icons.error;
          }
          _selectedColor = const Color.fromRGBO(87, 113, 255, 1);
        });
      }
      _customStatusController.text =
          AuthService().currentUser!.customStatus ?? "";
      _selectedCustomIcon =
          _iconOptions.entries
              .firstWhere(
                (entry) => entry.key == user.customIconStatus,
                orElse: () => MapEntry("", Icons.error),
              )
              .value;
    }
  }

  void _toggleDropdown() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _updateStatus(
    String status,
    IconData icon,
    Color color,
    bool customStatus,
  ) async {
    if (!customStatus)
      await AuthService().updateSingleUserField(
        status: status,
        iconStatus: _selectedIconKey,
      );
    else {
      await AuthService().updateSingleUserField(
        status: status,
        customStatus: status,
        customIconStatus: _selectedCustomIconKey,
      );
      AuthService().currentUser!.customStatus = status;
      AuthService().currentUser!.customIconStatus = _selectedCustomIconKey;
      AuthService().currentUser!.status = status;
    }

    setState(() {
      _selectedStatus = status;
      _selectedIcon = icon;
      _selectedColor = color;
      _isExpanded = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _initStatus();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 150,
    );

    if (pickedImage != null) {
      setState(() {
        _isEditingBackgroundImage
            ? _backgroundImage = File(pickedImage.path)
            : _profileImage = File(pickedImage.path);
      });
    }
    _isEditingBackgroundImage = false;
    _isButtonVisible = true;
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pushNamedAndRemoveUntil(
                    AppRoutes.AUTH_OR_APP_PAGE,
                    (Route<dynamic> route) => false,
                  );
                  AuthService().logout();
                },
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      setState(() {});
      return;
    }
    setState(() => _isLoading = true);
    if (_isButtonVisible &&
        !_isEditingEmail &&
        !_isEditingName &&
        !_isEditingPhone) {
      try {
        if (_profileImage != null)
          await AuthService().updateProfileImage(_profileImage);
        if (_backgroundImage != null)
          await AuthService().updateBackgroundImage(_backgroundImage);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imagem atualizado com sucesso!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar perfil: $error')),
        );
      }
    }

    if (_isEditingName)
      await AuthService().updateSingleUserField(
        firstName: _textController.text,
        lastName: _lastNameTextController.text,
      );

    if (_isEditingEmail) {
      await AuthService().updateSingleUserField(email: _textController.text);
      _showAlert(
        "Verificação necessária",
        "Um e-mail de confirmação foi enviado para ${_textController.text}. A sua sessão vai expirar.",
      );
    }

    if (_isEditingNickname)
      await AuthService().updateSingleUserField(nickname: _textController.text);
    if (_isEditingAboutMe)
      await AuthService().updateSingleUserField(aboutMe: _textController.text);

    setState(() {
      _isLoading = false;
      _isEditingName = false;
      _isEditingNickname = false;
      _isEditingAboutMe = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("O meu perfil", style: TextStyle(fontSize: 35)),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed:
                    () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.NOTIFICATION_PAGE),
                icon: Icon(Icons.notifications),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: CircleAvatar(
                  maxRadius: 9,
                  backgroundColor: Colors.red.shade800,
                  child: Text(
                    "${Provider.of<ChatNotificationService>(context).itemsCount}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () async {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                final chatNotifier = context.read<ChatListNotifier>();
                chatNotifier.clearChats();
                await AuthService().logout();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.AUTH_OR_APP_PAGE,
                  (route) => false,
                );
              });
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Stack(
        children: [
          Opacity(
            opacity:
                (_isEditingName || _isEditingEmail || _isEditingPhone)
                    ? 0.2
                    : 1,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (AuthService().currentUser != null) ...[
                      Stack(
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.25,
                            decoration: BoxDecoration(
                              image:
                                  _backgroundImage != null
                                      ? DecorationImage(
                                        image: FileImage(_backgroundImage!),
                                        fit: BoxFit.cover,
                                      )
                                      : (AuthService().currentUser != null &&
                                          AuthService()
                                                  .currentUser!
                                                  .backgroundUrl !=
                                              null)
                                      ? DecorationImage(
                                        image: NetworkImage(
                                          AuthService()
                                              .currentUser!
                                              .backgroundUrl!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                      : DecorationImage(
                                        image: AssetImage(
                                          'assets/images/background_logo.png',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                            ),
                            width: double.infinity,
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: TextButton(
                              child: Text(
                                (_backgroundImage == null)
                                    ? "Definir imagem"
                                    : "Mudar imagem",
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.grey,
                                textStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                _isEditingBackgroundImage = true;
                                _pickImage();
                              },
                            ),
                          ),
                          Visibility(
                            visible: _isButtonVisible,
                            child: Positioned(
                              bottom: 0,
                              right: 10,
                              child:
                                  (_isLoading)
                                      ? CircularProgressIndicator()
                                      : TextButton(
                                        child: Text("Guardar alterações"),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor:
                                              Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                          textStyle: TextStyle(fontSize: 12),
                                        ),
                                        // icon: Icon(Icons.edit, color: Colors.white),
                                        onPressed: _submit,
                                      ),
                            ),
                          ),
                          Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height * 0.18,
                                ),
                                child: Center(
                                  child: CircleAvatar(
                                    radius: 80,
                                    backgroundImage:
                                        _profileImage != null &&
                                                AuthService().currentUser !=
                                                    null
                                            ? FileImage(_profileImage!)
                                            : NetworkImage(
                                              AuthService()
                                                      .currentUser
                                                      ?.imageUrl ??
                                                  "",
                                            ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                left: MediaQuery.of(context).size.width * 0.30,
                                child: CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.surface,
                                  child: IconButton(
                                    onPressed: _pickImage,
                                    icon: Icon(Icons.photo_camera),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      UserInfoCardListTile(
                        titleText: "Nome Completo",
                        subTitleText:
                            "${AuthService().currentUser!.firstName} ${AuthService().currentUser!.lastName}",
                        icon: Icons.person,
                        onTap: () {
                          _textController.text =
                              AuthService().currentUser!.firstName;
                          _lastNameTextController.text =
                              AuthService().currentUser!.lastName;
                          setState(() {
                            _currentPopUpTextMessage =
                                "Introduza o seu primeiro nome:";
                            _isEditingName = true;
                          });
                        },
                      ),
                      // UserInfoCardListTile(
                      //   titleText: "E-mail",
                      //   subTitleText: AuthService().currentUser!.email,
                      //   icon: Icons.email_rounded,
                      //   onTap: () {
                      //     _textController.text = AuthService().currentUser!.email;
                      //     setState(() => _isEditingEmail = true);
                      //   },
                      // ),
                      UserInfoCardListTile(
                        titleText: "Aka (Mais conhecido por: )",
                        subTitleText:
                            AuthService().currentUser!.nickname ??
                            "Clique para personalizar",
                        icon: Icons.perm_identity_sharp,
                        onTap: () {
                          _textController.text =
                              AuthService().currentUser!.nickname ?? "";
                          setState(() {
                            _currentPopUpTextMessage =
                                "Introduza o seu nickname: ";
                            _isEditingNickname = true;
                          });
                        },
                      ),
                      SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: _toggleDropdown,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    _selectedIcon,
                                    color: _selectedColor,
                                  ),
                                  title: Text("Status"),
                                  subtitle: Text(_selectedStatus),
                                  trailing: Icon(
                                    _isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                  ),
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              height: _isExpanded ? 220 : 0,
                              width: double.infinity,
                              curve: Curves.fastOutSlowIn,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child:
                                  _isExpanded
                                      ? Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        margin: EdgeInsets.only(top: 4),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Status Personalizado",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        DropdownButton<
                                                          IconData
                                                        >(
                                                          value:
                                                              _selectedCustomIcon,
                                                          items:
                                                              _iconOptions.entries.map((
                                                                entry,
                                                              ) {
                                                                return DropdownMenuItem<
                                                                  IconData
                                                                >(
                                                                  onTap:
                                                                      () =>
                                                                          _selectedCustomIconKey =
                                                                              entry.key,
                                                                  value:
                                                                      entry
                                                                          .value,
                                                                  child: Icon(
                                                                    entry.value,
                                                                  ),
                                                                );
                                                              }).toList(),
                                                          onChanged: (newIcon) {
                                                            setState(() {
                                                              _selectedCustomIcon =
                                                                  newIcon!;
                                                            });
                                                          },
                                                        ),
                                                        SizedBox(width: 10),
                                                        Expanded(
                                                          child: TextFormField(
                                                            maxLength: 10,
                                                            controller:
                                                                _customStatusController,
                                                            decoration: InputDecoration(
                                                              hintText:
                                                                  "Como te sentes?",
                                                              border:
                                                                  OutlineInputBorder(),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 10),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            if (_customStatusController
                                                                .text
                                                                .isNotEmpty) {
                                                              _updateStatus(
                                                                _customStatusController
                                                                    .text,
                                                                _selectedCustomIcon,
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primary,
                                                                true,
                                                              );
                                                            }
                                                          },
                                                          child: Text(
                                                            (AuthService()
                                                                        .currentUser!
                                                                        .customStatus ==
                                                                    null)
                                                                ? "Criar"
                                                                : "Selecionar",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Lista de status padrão
                                              Column(
                                                children:
                                                    _statusOptions.map((
                                                      status,
                                                    ) {
                                                      return ListTile(
                                                        leading: Icon(
                                                          status["icon"],
                                                          color:
                                                              status["color"],
                                                        ),
                                                        title: Text(
                                                          status["text"],
                                                        ),
                                                        onTap: () {
                                                          _selectedIconKey =
                                                              status["key"];
                                                          _updateStatus(
                                                            status["text"],
                                                            status["icon"],
                                                            status["color"],
                                                            false,
                                                          );
                                                        },
                                                      );
                                                    }).toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      : SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                      UserInfoCardListTile(
                        titleText: "Sobre mim",
                        subTitleText:
                            AuthService().currentUser?.aboutMe ??
                            "Clique para personalizar",
                        icon: Icons.accessibility_outlined,
                        onTap: () {
                          _textController.text =
                              AuthService().currentUser!.aboutMe ?? "";
                          setState(() {
                            _currentPopUpTextMessage =
                                "Fale um pouco sobre si: ";
                            _isEditingAboutMe = true;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (_isEditingName || _isEditingNickname || _isEditingAboutMe)
            Padding(
              padding: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _currentPopUpTextMessage!,
                            textAlign: TextAlign.start,
                          ),
                        ),
                        if (_isEditingName ||
                            _isEditingNickname ||
                            _isEditingAboutMe)
                          TextFormField(
                            controller: _textController,
                            validator: (value) {
                              if (value!.trim().isEmpty || value.length < 3) {
                                setState(() {
                                  _errorMessage =
                                      "O campo precisa de ser preenchido.";
                                });
                                return _errorMessage;
                              }
                              setState(() {
                                _errorMessage = null;
                              });
                              return null;
                            },
                          ),
                        if (_isEditingName) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Introduza o último nome",
                              textAlign: TextAlign.start,
                            ),
                          ),
                          TextFormField(
                            controller: _lastNameTextController,
                            validator: (value) {
                              if (value!.trim().isEmpty || value.length < 3) {
                                setState(() {
                                  _errorMessage =
                                      "Informe um primeiro nome válido";
                                });
                                return _errorMessage;
                              }
                              setState(() {
                                _errorMessage = null;
                              });
                              return null;
                            },
                          ),
                        ],
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  if (_isEditingName ||
                                      _isEditingNickname ||
                                      _isEditingAboutMe) {
                                    _isEditingName = false;
                                    _isEditingNickname = false;
                                    _isEditingAboutMe = false;
                                  }
                                });
                              },
                              child: Text("Voltar"),
                            ),
                            _isLoading
                                ? CircularProgressIndicator()
                                : TextButton(
                                  onPressed: _submit,
                                  child: Text("Guardar"),
                                ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
