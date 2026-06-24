import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/lock_helper.dart';
import 'home_screen.dart';

class AppLockScreen extends StatefulWidget {
  final bool isAppLevel;
  const AppLockScreen({super.key, this.isAppLevel = false});
  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  String _pin = '';
  bool _error = false;

  void _onKey(String k) {
    if (_pin.length >= 4) return;
    setState(() { _pin += k; _error = false; });
    if (_pin.length == 4) _verify();
  }

  void _back() { if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1)); }

  Future<void> _verify() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final ok = await LockHelper.verifyAppPin(_pin);
    if (ok && mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      setState(() { _pin = ''; _error = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 40),
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF7C5CFC), Color(0xFFF472B6)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: const Color(0xFF7C5CFC).withOpacity(0.4), blurRadius: 30)],
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            Text('xRa', style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w700,
              foreground: Paint()..shader = const LinearGradient(
                colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
              ).createShader(const Rect.fromLTWH(0,0,100,40)))),
            const SizedBox(height: 6),
            Text('Enter PIN to continue', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B6B8A))),
            const SizedBox(height: 32),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 16, height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _error ? const Color(0xFFFF4D6A) : i < _pin.length ? const Color(0xFF7C5CFC) : Colors.transparent,
                  border: Border.all(color: _error ? const Color(0xFFFF4D6A) : i < _pin.length ? const Color(0xFF7C5CFC) : const Color(0xFF2A2A3E), width: 2),
                ),
              ))),
            if (_error) Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('Wrong PIN', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFFF4D6A))),
            ),
            const SizedBox(height: 32),
            GridView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.3, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: 12,
              itemBuilder: (_, i) {
                if (i == 9) return const SizedBox();
                if (i == 11) return GestureDetector(onTap: _back, child: _key(child: const Icon(Icons.backspace_rounded, color: Color(0xFF6B6B8A), size: 22)));
                final n = i == 10 ? '0' : '${i+1}';
                return GestureDetector(onTap: () => _onKey(n), child: _key(child: Text(n, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white))));
              },
            ),
          ]),
        ),
      ),
    );
  }

  Widget _key({required Widget child}) => Container(
    decoration: BoxDecoration(color: const Color(0xFF16161F), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF2A2A3E))),
    child: Center(child: child),
  );
}
