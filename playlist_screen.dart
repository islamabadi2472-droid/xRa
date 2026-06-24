import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../utils/database_helper.dart';
import 'playlist_lock_screen.dart';
import 'playlist_detail_screen.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  List<Playlist> _playlists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    final playlists = await DatabaseHelper.instance.getAllPlaylists();
    setState(() {
      _playlists = playlists;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C5CFC)))
                : _playlists.isEmpty
                    ? _buildEmpty()
                    : _buildList(),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPlaylist,
        backgroundColor: const Color(0xFF7C5CFC),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('New Playlist', style: GoogleFonts.inter(
          color: Colors.white, fontWeight: FontWeight.w600,
        )),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(children: [
      Text('Playlists', style: GoogleFonts.spaceGrotesk(
        fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white,
      )),
      const Spacer(),
      GestureDetector(
        onTap: () {},
        child: Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A26),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A3E)),
          ),
          child: const Icon(Icons.search_rounded, color: Color(0xFF6B6B8A), size: 18),
        ),
      ),
    ]),
  );

  Widget _buildList() => ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
    itemCount: _playlists.length,
    itemBuilder: (_, i) => _buildPlaylistCard(_playlists[i]),
  );

  Widget _buildPlaylistCard(Playlist playlist) => GestureDetector(
    onTap: () => _openPlaylist(playlist),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A3E)),
      ),
      child: Row(children: [
        Container(
          width: 56, height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getGradient(playlist.id ?? 0),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(
            playlist.coverEmoji ?? '🎬',
            style: const TextStyle(fontSize: 22),
          )),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(playlist.name, style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white,
            )),
            FutureBuilder<int>(
              future: DatabaseHelper.instance.getVideoCount(playlist.id ?? 0),
              builder: (_, snap) => Text(
                '${snap.data ?? 0} videos',
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B6B8A)),
              ),
            ),
          ],
        )),
        GestureDetector(
          onTap: () => _toggleLock(playlist),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: playlist.isLocked ? const Color(0xFF1e1535) : const Color(0xFF0d2e1e),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              playlist.isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
              color: playlist.isLocked ? const Color(0xFFA78BFA) : const Color(0xFF34D399),
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          color: const Color(0xFF16161F),
          icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF6B6B8A)),
          onSelected: (val) => _handleMenu(val, playlist),
          itemBuilder: (_) => [
            _menuItem('edit', Icons.edit_rounded, 'Edit'),
            _menuItem('lock', Icons.lock_rounded, playlist.isLocked ? 'Remove Lock' : 'Set Lock'),
            _menuItem('delete', Icons.delete_rounded, 'Delete'),
          ],
        ),
      ]),
    ),
  );

  PopupMenuItem<String> _menuItem(String val, IconData icon, String label) =>
    PopupMenuItem(
      value: val,
      child: Row(children: [
        Icon(icon, color: const Color(0xFF6B6B8A), size: 16),
        const SizedBox(width: 10),
        Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
      ]),
    );

  List<Color> _getGradient(int id) {
    final gradients = [
      [const Color(0xFF1a0a30), const Color(0xFF3b1a6e)],
      [const Color(0xFF0d2e1e), const Color(0xFF1a5c38)],
      [const Color(0xFF2e0d0d), const Color(0xFF6e1a1a)],
      [const Color(0xFF1a1a0d), const Color(0xFF5c5c1a)],
      [const Color(0xFF0d1a2e), const Color(0xFF1a3a6e)],
    ];
    return gradients[id % gradients.length];
  }

  void _openPlaylist(Playlist playlist) {
    if (playlist.isLocked) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => PlaylistLockScreen(playlist: playlist),
      ));
    } else {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => PlaylistDetailScreen(playlist: playlist),
      ));
    }
  }

  void _toggleLock(Playlist playlist) {
    if (playlist.isLocked) {
      _showUnlockDialog(playlist);
    } else {
      _showSetPinDialog(playlist);
    }
  }

  void _showSetPinDialog(Playlist playlist) {
    showDialog(
      context: context,
      builder: (_) => _SetPinDialog(
        playlist: playlist,
        onPinSet: (pin) async {
          final updated = playlist.copyWith(
            isLocked: true,
            pinHash: _hashPin(pin),
          );
          await DatabaseHelper.instance.updatePlaylist(updated);
          _loadPlaylists();
        },
      ),
    );
  }

  void _showUnlockDialog(Playlist playlist) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF16161F),
        title: Text('Remove Lock', style: GoogleFonts.inter(color: Colors.white)),
        content: Text('Remove lock from "${playlist.name}"?',
          style: GoogleFonts.inter(color: const Color(0xFF6B6B8A))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFF6B6B8A)))),
          TextButton(
            onPressed: () async {
              final updated = playlist.copyWith(isLocked: false, pinHash: null);
              await DatabaseHelper.instance.updatePlaylist(updated);
              Navigator.pop(context);
              _loadPlaylists();
            },
            child: Text('Remove', style: GoogleFonts.inter(color: const Color(0xFFFF4D6A))),
          ),
        ],
      ),
    );
  }

  void _handleMenu(String action, Playlist playlist) {
    switch (action) {
      case 'edit': _editPlaylist(playlist); break;
      case 'lock': _toggleLock(playlist); break;
      case 'delete': _deletePlaylist(playlist); break;
    }
  }

  void _editPlaylist(Playlist playlist) {
    // TODO: Show edit dialog
  }

  void _deletePlaylist(Playlist playlist) async {
    await DatabaseHelper.instance.deletePlaylist(playlist.id!);
    _loadPlaylists();
  }

  void _createPlaylist() {
    showDialog(
      context: context,
      builder: (_) => _CreatePlaylistDialog(
        onCreate: (name, emoji) async {
          final playlist = Playlist(
            name: name,
            coverEmoji: emoji,
            createdAt: DateTime.now(),
          );
          await DatabaseHelper.instance.insertPlaylist(playlist);
          _loadPlaylists();
        },
      ),
    );
  }

  String _hashPin(String pin) {
    // Simple hash for demo - use LockHelper.hashPin in production
    return pin.hashCode.toString();
  }

  Widget _buildEmpty() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('📋', style: TextStyle(fontSize: 60)),
      const SizedBox(height: 16),
      Text('No Playlists Yet', style: GoogleFonts.spaceGrotesk(
        fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white,
      )),
      const SizedBox(height: 8),
      Text('Create a playlist to organize your videos', style: GoogleFonts.inter(
        fontSize: 13, color: const Color(0xFF6B6B8A),
      )),
    ]),
  );
}

// ── CREATE PLAYLIST DIALOG ──
class _CreatePlaylistDialog extends StatefulWidget {
  final Function(String name, String emoji) onCreate;
  const _CreatePlaylistDialog({required this.onCreate});

  @override
  State<_CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<_CreatePlaylistDialog> {
  final _nameCtrl = TextEditingController();
  String _selectedEmoji = '🎬';
  final _emojis = ['🎬', '🎵', '🎧', '📚', '🏋️', '🎮', '🎨', '❤️', '🔥', '⭐'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF16161F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('New Playlist', style: GoogleFonts.spaceGrotesk(
        color: Colors.white, fontWeight: FontWeight.w700,
      )),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _emojis.map((e) => GestureDetector(
            onTap: () => setState(() => _selectedEmoji = e),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedEmoji == e ? const Color(0xFF1e1535) : const Color(0xFF1A1A26),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _selectedEmoji == e ? const Color(0xFF7C5CFC) : const Color(0xFF2A2A3E),
                ),
              ),
              child: Text(e, style: const TextStyle(fontSize: 20)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Playlist name...',
            hintStyle: const TextStyle(color: Color(0xFF6B6B8A)),
            filled: true,
            fillColor: const Color(0xFF1A1A26),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A3E)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A3E)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF7C5CFC)),
            ),
          ),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.inter(color: const Color(0xFF6B6B8A)))),
        ElevatedButton(
          onPressed: () {
            if (_nameCtrl.text.isNotEmpty) {
              widget.onCreate(_nameCtrl.text, _selectedEmoji);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C5CFC),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Create', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

// ── SET PIN DIALOG ──
class _SetPinDialog extends StatefulWidget {
  final Playlist playlist;
  final Function(String pin) onPinSet;
  const _SetPinDialog({required this.playlist, required this.onPinSet});

  @override
  State<_SetPinDialog> createState() => _SetPinDialogState();
}

class _SetPinDialogState extends State<_SetPinDialog> {
  String _pin = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF16161F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Set PIN Lock', style: GoogleFonts.spaceGrotesk(
        color: Colors.white, fontWeight: FontWeight.w700,
      )),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Enter a 4-digit PIN for "${widget.playlist.name}"',
          style: GoogleFonts.inter(color: const Color(0xFF6B6B8A), fontSize: 12),
          textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (i) => Container(
            width: 16, height: 16,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < _pin.length ? const Color(0xFF7C5CFC) : Colors.transparent,
              border: Border.all(color: i < _pin.length ? const Color(0xFF7C5CFC) : const Color(0xFF2A2A3E), width: 2),
            ),
          )),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 1.4,
            crossAxisSpacing: 8, mainAxisSpacing: 8,
          ),
          itemCount: 12,
          itemBuilder: (_, i) {
            if (i == 9) return const SizedBox();
            if (i == 11) {
              return GestureDetector(
                onTap: () => setState(() { if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1); }),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A26),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2A3E)),
                  ),
                  child: const Icon(Icons.backspace_rounded, color: Color(0xFF6B6B8A), size: 20),
                ),
              );
            }
            final num = i == 10 ? 0 : i + 1;
            return GestureDetector(
              onTap: () {
                if (_pin.length < 4) {
                  setState(() => _pin += num.toString());
                  if (_pin.length == 4) {
                    Future.delayed(const Duration(milliseconds: 300), () {
                      widget.onPinSet(_pin);
                      Navigator.pop(context);
                    });
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A3E)),
                ),
                child: Center(child: Text('$num', style: GoogleFonts.inter(
                  fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white,
                ))),
              ),
            );
          },
        ),
      ]),
    );
  }
}
