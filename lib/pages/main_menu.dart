import 'package:harvestly/pages/new_chat_page.dart';
import 'package:harvestly/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/chat/chat_list_notifier.dart';
import '../pages/chat_list_page.dart';
import 'conections_page.dart';
import '../pages/settings_page.dart';
import '../core/services/auth/auth_service.dart';
import '../utils/app_routes.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isSearching = false;
  String _profileImageUrl = "";

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isSearching = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _profileImageUrl = AuthService().currentUser?.imageUrl ?? "";
    _selectedIndex = 0;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = Provider.of<ChatListNotifier>(context, listen: false);
      notifier.clearChats();
      notifier.listenToChats();
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        Provider.of<ChatListNotifier>(
          context,
          listen: false,
        ).setSearchQuery("");
      }
    });
  }

  void _navigateToPage(String route) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => _getPage(route),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _getPage(String route) {
    switch (route) {
      case AppRoutes.PROFILE_PAGE:
        return ProfilePage();
      case AppRoutes.NEW_CHAT_PAGE:
        return NewChatPage();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      ChatListPage(),
      ConectionsPage(),
      SettingsPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text("Harvestly", style: TextStyle(fontFamily: "Barriecito")),
        actions: [
          if (_selectedIndex == 0)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child:
                  _isSearching
                      ? Padding(
                        key: const ValueKey(1),
                        padding: const EdgeInsets.all(8),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: SearchBar(
                            autoFocus: true,
                            hintText: "Procurar...",
                            onChanged: (query) {
                              Provider.of<ChatListNotifier>(
                                context,
                                listen: false,
                              ).setSearchQuery(query);
                            },
                            trailing: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isSearching = false;
                                  });
                                  Provider.of<ChatListNotifier>(
                                    context,
                                    listen: false,
                                  ).setSearchQuery("");
                                },
                                icon: Icon(Icons.close, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                      : IconButton(
                        key: const ValueKey(2),
                        icon: const Icon(Icons.search),
                        onPressed: _toggleSearch,
                      ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: InkWell(
              onTap: () => _navigateToPage(AppRoutes.PROFILE_PAGE),
              child:
                  AuthService().currentUser != null
                      ? CircleAvatar(
                        backgroundImage: NetworkImage(_profileImageUrl),
                      )
                      : Container(),
            ),
          ),
        ],
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor:
                    Theme.of(context).floatingActionButtonTheme.foregroundColor,
                onPressed: () => _navigateToPage(AppRoutes.NEW_CHAT_PAGE),
                child: const Icon(Icons.add),
              )
              : null,
      body: FadeTransition(
        opacity: _opacityAnimation,
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).bottomAppBarTheme.color,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Conversas"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Conexões"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Definições",
          ),
        ],
      ),
    );
  }
}
