import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../utils/lock_helper.dart';
import 'playlist_detail_screen.dart';

class PlaylistLockScreen extends StatefulWidget {
  final Playlist playlist;
  const PlaylistLockScreen({super.key, required this.playlist});

  @override
  State<PlaylistLockScreen> createState() => _PlaylistLockScreenState();
}

class _PlaylistLockScreenState extends State<PlaylistLockScreen>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  bool _error = false;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    if (widget.playlist.biometricEnabled) {
      final ok = await LockHelper.authenticateWithBiometrics(
        reason: 'Unlock ${widget.playlist.name}',
      );
      if (ok && mounted) _unlock();
    }
  }

  void _onKey(String key) {
    if (_enteredPin.length >= 4) return;
    setState(() {
      _enteredPin += key;
      _error = false;
    });
    if (_enteredPin.length == 4) _checkPin();
  }

  void _backspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() => _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1));
    }
  }

  void _checkPin() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final correct = LockHelper.verifyPin(_enteredPin, widget.playlist.pinHash ?? '');
    if (correct) {
      _unlock();
    } else {
      setState(() { _enteredPin = ''; _error = true; });
      _shakeCtrl.forward(from: 0);
    }
  }

  void _unlock() {
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => PlaylistDetailScreen(playlist: widget.playlist),
    ));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1e1535), Color(0xFF2a1a4e)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF7C5CFC), width: 2),
                  boxShadow: [BoxShadow(
                    color: const Color(0xFF7C5CFC).withOpacity(0.3),
                    blurRadius: 30, spreadRadius: 4,
                  )],
                ),
                child: const Icon(Icons.lock_rounded, color: Color(0xFFA78BFA), size: 36),
              ),
              const SizedBox(height: 20),
              Text(widget.playlist.name, style: GoogleFonts.spaceGrotesk(
                fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white,
              )),
              const SizedBox(height: 6),
              Text('Enter PIN to unlock', style: GoogleFonts.inter(
                fontSize: 13, color: const Color(0xFF6B6B8A),
              )),
              const SizedBox(height: 32),

              // PIN Dots
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(_shakeCtrl.isAnimating ? _shakeAnim.value * (_shakeCtrl.value < 0.5 ? 1 : -1) : 0, 0),
                  child: child,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 16, height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _error
                          ? const Color(0xFFFF4D6A)
                          : i < _enteredPin.length
                              ? const Color(0xFF7C5CFC)
                              : Colors.transparent,
                      border: Border.all(
                        color: _error
                            ? const Color(0xFFFF4D6A)
                            : i < _enteredPin.length
                                ? const Color(0xFF7C5CFC)
                                : const Color(0xFF2A2A3E),
                        width: 2,
                      ),
                      boxShadow: i < _enteredPin.length && !_error
                          ? [BoxShadow(color: const Color(0xFF7C5CFC).withOpacity(0.5), blurRadius: 8)]
                          : null,
                    ),
                  )),
                ),
              ),
              if (_error)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text('Wrong PIN. Try again.',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFFF4D6A))),
                ),
              const SizedBox(height: 32),

              // PIN Keypad
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 1.3,
                  crossAxisSpacing: 12, mainAxisSpacing: 12,
                ),
                itemCount: 12,
                itemBuilder: (_, i) {
                  if (i == 9) return const SizedBox();
                  if (i == 11) {
                    return GestureDetector(
                      onTap: _backspace,
                      child: _keyContainer(
                        child: const Icon(Icons.backspace_rounded,
                          color: Color(0xFF6B6B8A), size: 22),
                      ),
                    );
                  }
                  final num = i == 10 ? '0' : '${i + 1}';
                  return GestureDetector(
                    onTap: () => _onKey(num),
                    child: _keyContainer(
                      child: Text(num, style: GoogleFonts.inter(
                        fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white,
                      )),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Biometric button
              FutureBuilder<bool>(
                future: LockHelper.isBiometricAvailable(),
                builder: (_, snap) {
                  if (snap.data != true) return const SizedBox();
                  return GestureDetector(
                    onTap: _tryBiometric,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A26),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF2A2A3E)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.fingerprint_rounded,
                          color: Color(0xFFA78BFA), size: 22),
                        const SizedBox(width: 8),
                        Text('Use Fingerprint', style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: const Color(0xFFA78BFA),
                        )),
                      ]),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _keyContainer({required Widget child}) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF16161F),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFF2A2A3E)),
    ),
    child: Center(child: child),
  );
}
