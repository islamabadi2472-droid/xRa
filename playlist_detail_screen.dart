import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../utils/database_helper.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;
  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  List<VideoItem> _videos = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final videos = await DatabaseHelper.instance.getVideosByPlaylist(widget.playlist.id ?? 0);
    setState(() => _videos = videos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: Text(widget.playlist.name),
        backgroundColor: const Color(0xFF0A0A0F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _videos.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('🎬', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text('No Videos Yet', style: GoogleFonts.spaceGrotesk(
                fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white,
              )),
              const SizedBox(height: 8),
              Text('Downloaded videos will appear here', style: GoogleFonts.inter(
                fontSize: 13, color: const Color(0xFF6B6B8A),
              )),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _videos.length,
              itemBuilder: (_, i) => _buildVideoCard(_videos[i]),
            ),
    );
  }

  Widget _buildVideoCard(VideoItem video) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFF16161F),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF2A2A3E)),
    ),
    child: Row(children: [
      Container(
        width: 80, height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1e1535), Color(0xFF2a1a4e)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.play_arrow_rounded, color: Color(0xFF7C5CFC), size: 30),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(video.title, style: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
        ), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text('${video.durationFormatted} • ${video.fileSizeFormatted}',
          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B6B8A))),
      ])),
      PopupMenuButton<String>(
        color: const Color(0xFF16161F),
        icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF6B6B8A)),
        onSelected: (val) {},
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'play', child: Text('Play', style: TextStyle(color: Colors.white))),
          const PopupMenuItem(value: 'move', child: Text('Move to Playlist', style: TextStyle(color: Colors.white))),
          const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Color(0xFFFF4D6A)))),
        ],
      ),
    ]),
  );
}
