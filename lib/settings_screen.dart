import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/lock_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _appLock = false;
  bool _biometric = false;
  String _downloadPath = '/storage/emulated/0/xRa/Downloads';

  @override
  void initState() {
    super.initState();
    LockHelper.isAppLockEnabled().then((v) => setState(() => _appLock = v));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20,16,20,12),
          child: Row(children: [
            Text('Settings', style: GoogleFonts.spaceGrotesk(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
          ]),
        ),
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          _section('Security'),
          _tile('App Lock', 'Protect app with PIN', Icons.lock_rounded,
            trailing: Switch(value: _appLock, onChanged: _toggleAppLock, activeColor: const Color(0xFF7C5CFC))),
          _tile('Biometric', 'Use fingerprint to unlock', Icons.fingerprint_rounded,
            trailing: Switch(value: _biometric, onChanged: (v) => setState(() => _biometric = v), activeColor: const Color(0xFF7C5CFC))),
          _section('Downloads'),
          _tile('Download Path', _downloadPath, Icons.folder_rounded, onTap: () {}),
          _tile('Auto-add to Playlist', 'Choose default playlist', Icons.playlist_add_rounded, onTap: () {}),
          _section('Player'),
          _tile('Default Quality', '1080p', Icons.hd_rounded, onTap: () {}),
          _tile('Subtitle Language', 'Auto Detect', Icons.subtitles_rounded, onTap: () {}),
          _section('About'),
          _tile('Version', 'xRa v1.0.0', Icons.info_rounded),
          _tile('Clear Cache', 'Free up storage', Icons.cleaning_services_rounded, onTap: () {}),
        ])),
      ])),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
    child: Text(title.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF6B6B8A), letterSpacing: 0.8)),
  );

  Widget _tile(String title, String sub, IconData icon, {Widget? trailing, VoidCallback? onTap}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: const Color(0xFF16161F), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF2A2A3E))),
        child: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFF1A1A26), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF7C5CFC), size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            Text(sub, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B6B8A))),
          ])),
          if (trailing != null) trailing
          else if (onTap != null) const Icon(Icons.chevron_right_rounded, color: Color(0xFF6B6B8A)),
        ]),
      ),
    );

  Future<void> _toggleAppLock(bool val) async {
    if (val) {
      // Show PIN setup dialog
      setState(() => _appLock = true);
    } else {
      await LockHelper.removeAppLock();
      setState(() => _appLock = false);
    }
  }
}
