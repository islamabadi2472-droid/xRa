import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'downloader_screen.dart';
import 'player_screen.dart';
import 'playlist_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DownloaderScreen(),
    PlayerScreen(),
    PlaylistScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF12121A),
          border: Border(top: BorderSide(color: Color(0xFF2A2A3E))),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.download_rounded, label: 'Download', index: 0, current: _currentIndex, onTap: _onTap),
                _NavItem(icon: Icons.play_circle_rounded, label: 'Player', index: 1, current: _currentIndex, onTap: _onTap),
                _NavItem(icon: Icons.queue_music_rounded, label: 'Playlists', index: 2, current: _currentIndex, onTap: _onTap),
                _NavItem(icon: Icons.settings_rounded, label: 'Settings', index: 3, current: _currentIndex, onTap: _onTap),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(int index) => setState(() => _currentIndex = index);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1e1535) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isActive ? const Color(0xFFA78BFA) : const Color(0xFF6B6B8A),
                size: 24),
            const SizedBox(height: 3),
            Text(label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isActive ? const Color(0xFFA78BFA) : const Color(0xFF6B6B8A),
                  letterSpacing: 0.3,
                )),
          ],
        ),
      ),
    );
  }
}
