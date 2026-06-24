import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../utils/database_helper.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  List<VideoItem> _allVideos = [];
  VideoItem? _currentVideo;
  double _playbackSpeed = 1.0;
  bool _isPlaying = false;
  bool _nightMode = false;

  final List<double> _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    final videos = await DatabaseHelper.instance.getAllVideos();
    setState(() => _allVideos = videos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _nightMode ? Colors.black : const Color(0xFF0A0A0F),
      body: SafeArea(
        child: Column(children: [
          _buildHeader(),
          _buildVideoArea(),
          _buildOptions(),
          _buildControls(),
          Expanded(child: _buildVideoList()),
        ]),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(children: [
      Text('Player', style: GoogleFonts.spaceGrotesk(
        fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white,
      )),
      const Spacer(),
      GestureDetector(
        onTap: () => setState(() => _nightMode = !_nightMode),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _nightMode ? const Color(0xFF1e1535) : const Color(0xFF1A1A26),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _nightMode ? const Color(0xFF7C5CFC) : const Color(0xFF2A2A3E),
            ),
          ),
          child: Row(children: [
            Icon(Icons.nightlight_round,
              color: _nightMode ? const Color(0xFFA78BFA) : const Color(0xFF6B6B8A),
              size: 16),
            const SizedBox(width: 4),
            Text('Night', style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: _nightMode ? const Color(0xFFA78BFA) : const Color(0xFF6B6B8A),
            )),
          ]),
        ),
      ),
    ]),
  );

  Widget _buildVideoArea() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2A2A3E)),
        ),
        child: Stack(children: [
          // Video background
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF0d0520), Color(0xFF1a0a30)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
          ),
          // Play button center
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _isPlaying = !_isPlaying),
              child: Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C5CFC).withOpacity(0.85),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: const Color(0xFF7C5CFC).withOpacity(0.5),
                    blurRadius: 20,
                  )],
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white, size: 32,
                ),
              ),
            ),
          ),
          // Video title overlay
          if (_currentVideo != null)
            Positioned(
              bottom: 12, left: 12, right: 12,
              child: Text(_currentVideo!.title, style: GoogleFonts.inter(
                fontSize: 12, color: Colors.white,
                shadows: [const Shadow(blurRadius: 4, color: Colors.black)],
              ), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          if (_currentVideo == null)
            Center(child: Text('Select a video\nto play',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B6B8A)),
            )),
        ]),
      ),
    ),
  );

  Widget _buildOptions() => Padding(
    padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: [
        _optChip(Icons.volume_up_rounded, 'Audio'),
        _optChip(Icons.subtitles_rounded, 'Subtitle'),
        _optChip(Icons.aspect_ratio_rounded, 'Ratio'),
        _optChip(Icons.repeat_rounded, 'Loop'),
        _optChip(Icons.equalizer_rounded, 'EQ'),
        _optChip(Icons.cast_rounded, 'Cast'),
        _optChip(Icons.picture_in_picture_alt_rounded, 'PiP'),
      ]),
    ),
  );

  Widget _optChip(IconData icon, String label) => Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: const Color(0xFF16161F),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF2A2A3E)),
    ),
    child: Row(children: [
      Icon(icon, color: const Color(0xFF6B6B8A), size: 14),
      const SizedBox(width: 5),
      Text(label, style: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF6B6B8A),
      )),
    ]),
  );

  Widget _buildControls() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Column(children: [
      // Seekbar
      Container(
        height: 4, width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A3E),
          borderRadius: BorderRadius.circular(4),
        ),
        child: FractionallySizedBox(
          widthFactor: 0.38, alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C5CFC), Color(0xFFF472B6)],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('1:24', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF6B6B8A))),
          Text('3:42', style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF6B6B8A))),
        ],
      ),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _ctrlBtn(Icons.skip_previous_rounded, () {}),
        _ctrlBtn(Icons.fast_rewind_rounded, () {}),
        _ctrlBtn(Icons.play_arrow_rounded, () => setState(() => _isPlaying = !_isPlaying), primary: true),
        _ctrlBtn(Icons.fast_forward_rounded, () {}),
        _ctrlBtn(Icons.skip_next_rounded, () {}),
      ]),
      const SizedBox(height: 10),
      // Speed selector
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _speeds.map((s) {
            final isSelected = _playbackSpeed == s;
            return GestureDetector(
              onTap: () => setState(() => _playbackSpeed = s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1e1535) : const Color(0xFF1A1A26),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFA78BFA) : const Color(0xFF2A2A3E),
                  ),
                ),
                child: Text('${s}x', style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: isSelected ? const Color(0xFFA78BFA) : const Color(0xFF6B6B8A),
                )),
              ),
            );
          }).toList(),
        ),
      ),
    ]),
  );

  Widget _ctrlBtn(IconData icon, VoidCallback onTap, {bool primary = false}) =>
    GestureDetector(
      onTap: onTap,
      child: Container(
        width: primary ? 50 : 40,
        height: primary ? 50 : 40,
        decoration: BoxDecoration(
          color: primary ? const Color(0xFF7C5CFC) : const Color(0xFF1A1A26),
          borderRadius: BorderRadius.circular(primary ? 14 : 11),
          border: Border.all(color: primary ? const Color(0xFF7C5CFC) : const Color(0xFF2A2A3E)),
        ),
        child: Icon(icon, color: Colors.white, size: primary ? 26 : 20),
      ),
    );

  Widget _buildVideoList() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
        child: Text('ALL VIDEOS', style: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: const Color(0xFF6B6B8A), letterSpacing: 0.8,
        )),
      ),
      Expanded(
        child: _allVideos.isEmpty
            ? Center(child: Text('No videos downloaded yet',
                style: GoogleFonts.inter(color: const Color(0xFF6B6B8A))))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _allVideos.length,
                itemBuilder: (_, i) => _buildVideoListItem(_allVideos[i]),
              ),
      ),
    ],
  );

  Widget _buildVideoListItem(VideoItem video) => GestureDetector(
    onTap: () => setState(() {
      _currentVideo = video;
      _isPlaying = true;
    }),
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _currentVideo?.id == video.id ? const Color(0xFF1e1535) : const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _currentVideo?.id == video.id ? const Color(0xFF7C5CFC) : const Color(0xFF2A2A3E),
        ),
      ),
      child: Row(children: [
        Container(
          width: 60, height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.play_circle_outline_rounded,
            color: Color(0xFF7C5CFC), size: 24),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(video.title, style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white,
          ), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(video.durationFormatted, style: GoogleFonts.inter(
            fontSize: 10, color: const Color(0xFF6B6B8A),
          )),
        ])),
        Icon(
          _currentVideo?.id == video.id ? Icons.volume_up_rounded : Icons.play_arrow_rounded,
          color: _currentVideo?.id == video.id ? const Color(0xFF7C5CFC) : const Color(0xFF6B6B8A),
          size: 18,
        ),
      ]),
    ),
  );
}
