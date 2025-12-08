import 'package:flutter/material.dart';
import 'package:edurise/core/theme/app_colors.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/ai_chat/presentation/pages/ai_chat_page.dart';
import '../features/courses/presentation/pages/courses_page.dart';
import '../features/marketplace/presentation/pages/marketplace_page.dart';
import '../features/tests/presentation/pages/tests_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _openAIChat() async {
    try {
      await Navigator.of(context).push(MaterialPageRoute(builder: (_) {
        try {
          return const AiChatPage();
        } catch (e) {
          return Scaffold(
            appBar: AppBar(title: const Text('AI Чат — ошибка')),
            body: Center(child: Text('Не удалось инициализировать AI чат: $e')),
          );
        }
      }));
    } catch (e) {
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(title: const Text('Ошибка'), content: Text('Не удалось открыть AI чат: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      body: IndexedStack(
        index: _index,
        children: const [
          HomePage(),
          CoursesPage(),
          TestsPage(),
          MarketplacePage(),
          // ProfilePage(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.transparent,
        child: PhysicalModel(
          color: Colors.white,
          elevation: 8,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 72,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
            child: Stack(
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _NavItem(
                        index: 0,
                        selected: _index == 0,
                        icon: Icons.home,
                        label: 'Главная',
                        onTap: () => setState(() => _index = 0),
                      ),
                      _NavItem(
                        index: 1,
                        selected: _index == 1,
                        icon: Icons.school,
                        label: 'Курсы',
                        onTap: () => setState(() => _index = 1),
                      ),
                      const SizedBox(width: 56),
                      _NavItem(
                        index: 2,
                        selected: _index == 2,
                        icon: Icons.assignment,
                        label: 'Тесты',
                        onTap: () => setState(() => _index = 2),
                      ),
                      _NavItem(
                        index: 3,
                        selected: _index == 3,
                        icon: Icons.store,
                        label: 'Маркет',
                        onTap: () => setState(() => _index = 3),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Transform.translate(
                    offset: const Offset(0, -16),
                    child: GestureDetector(
                      onTap: _openAIChat,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 80, 182, 255).withOpacity(0.6),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset( 'assets/icons/ai.png')
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _NavItem({required this.index, required this.selected, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: selected ? appPrimary : appSecondary, size: 26),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: selected ? appPrimary : appSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
