import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../models/models.dart';

class DownloaderScreen extends StatefulWidget {
  const DownloaderScreen({super.key});

  @override
  State<DownloaderScreen> createState() => _DownloaderScreenState();
}

class _DownloaderScreenState extends State<DownloaderScreen> {
  final _urlController = TextEditingController();
  String _selectedQuality = '1080p';
  String _selectedFormat = 'MP4';
  String _selectedPlatform = 'YouTube';

  final List<String> _qualities = ['MP3', '360p', '720p', '1080p', '4K'];
  final List<String> _formats = ['MP4', 'MP3', 'MKV', 'AVI'];

  final List<Map<String, String>> _platforms = [
    {'name': 'YouTube', 'icon': '📺'},
    {'name': 'Instagram', 'icon': '📸'},
    {'name': 'TikTok', 'icon': '🎵'},
    {'name': 'Twitter', 'icon': '🐦'},
    {'name': 'Facebook', 'icon': '📘'},
    {'name': 'Vimeo', 'icon': '🎬'},
    {'name': 'Twitch', 'icon': '🎮'},
    {'name': 'Others', 'icon': '🌐'},
  ];

  // Demo downloads list
  final List<DownloadTask> _downloads = [
    DownloadTask(
      id: '1',
      url: '',
      title: 'Arijit Singh Best Songs Mix',
      quality: '1080p',
      format: 'MP4',
      platform: 'youtube',
      status: DownloadStatus.downloading,
      progress: 0.72,
      startedAt: DateTime.now(),
    ),
    DownloadTask(
      id: '2',
      url: '',
      title: 'Tum Hi Ho – Audio',
      quality: 'MP3',
      format: 'MP3',
      platform: 'youtube',
      status: DownloadStatus.completed,
      progress: 1.0,
      startedAt: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildUrlInput()),
            SliverToBoxAdapter(child: _buildPlatforms()),
            SliverToBoxAdapter(child: _buildQualityRow()),
            SliverToBoxAdapter(child: _buildFormatRow()),
            SliverToBoxAdapter(child: _buildDownloadBtn()),
            SliverToBoxAdapter(child: _buildDownloadsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
    child: Row(
      children: [
        Text('xRa', style: GoogleFonts.spaceGrotesk(
          fontSize: 26, fontWeight: FontWeight.w700,
          foreground: Paint()..shader = const LinearGradient(
            colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
          ).createShader(const Rect.fromLTWH(0, 0, 80, 30)),
        )),
        const Spacer(),
        _iconBtn(Icons.history_rounded, () {}),
        const SizedBox(width: 8),
        _iconBtn(Icons.notifications_outlined, () {}),
      ],
    ),
  );

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A3E)),
      ),
      child: Icon(icon, color: const Color(0xFF6B6B8A), size: 18),
    ),
  );

  Widget _buildUrlInput() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A3E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PASTE VIDEO LINK', style: GoogleFonts.inter(
            fontSize: 10, color: const Color(0xFF6B6B8A),
            fontWeight: FontWeight.w600, letterSpacing: 1.2,
          )),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _urlController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'https://youtube.com/watch?v=...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _pasteFromClipboard,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C5CFC), Color(0xFF5B3DD8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('📋 Paste', style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white,
                )),
              ),
            ),
          ]),
        ],
      ),
    ),
  );

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      setState(() => _urlController.text = data!.text!);
    }
  }

  Widget _buildPlatforms() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle('Supported Platforms'),
      GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, childAspectRatio: 0.9,
          crossAxisSpacing: 10, mainAxisSpacing: 10,
        ),
        itemCount: _platforms.length,
        itemBuilder: (_, i) {
          final p = _platforms[i];
          final isSelected = _selectedPlatform == p['name'];
          return GestureDetector(
            onTap: () => setState(() => _selectedPlatform = p['name']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1e1535) : const Color(0xFF16161F),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? const Color(0xFF7C5CFC) : const Color(0xFF2A2A3E),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(p['icon']!, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(p['name']!, style: GoogleFonts.inter(
                    fontSize: 9, color: const Color(0xFF6B6B8A), fontWeight: FontWeight.w500,
                  )),
                ],
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 14),
    ],
  );

  Widget _buildQualityRow() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle('Video Quality'),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _qualities.map((q) {
            final isSelected = _selectedQuality == q;
            return GestureDetector(
              onTap: () => setState(() => _selectedQuality = q),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF7C5CFC) : const Color(0xFF1A1A26),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF7C5CFC) : const Color(0xFF2A2A3E),
                  ),
                ),
                child: Text(q, style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF6B6B8A),
                )),
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 14),
    ],
  );

  Widget _buildFormatRow() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle('Format'),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _formats.map((f) {
            final isSelected = _selectedFormat == f;
            return GestureDetector(
              onTap: () => setState(() => _selectedFormat = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1e1535) : const Color(0xFF1A1A26),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFA78BFA) : const Color(0xFF2A2A3E),
                  ),
                ),
                child: Text(f, style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFFA78BFA) : const Color(0xFF6B6B8A),
                )),
              ),
            );
          }).toList(),
        ),
      ),
      const SizedBox(height: 14),
    ],
  );

  Widget _buildDownloadBtn() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: GestureDetector(
      onTap: _startDownload,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C5CFC), Color(0xFF5B3DD8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: const Color(0xFF7C5CFC).withOpacity(0.4),
                blurRadius: 20, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.download_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text('Download Now', style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white,
            )),
          ],
        ),
      ),
    ),
  );

  void _startDownload() {
    if (_urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste a video URL first!')),
      );
      return;
    }
    // TODO: Integrate actual download logic with yt-dlp
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download started! 🚀')),
    );
  }

  Widget _buildDownloadsList() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle('Downloads'),
      ..._downloads.map((task) => _buildDownloadItem(task)),
      const SizedBox(height: 80),
    ],
  );

  Widget _buildDownloadItem(DownloadTask task) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A3E)),
      ),
      child: Row(children: [
        Container(
          width: 52, height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1e1535), Color(0xFF2a1a4e)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Text(task.platformIcon, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: GoogleFonts.inter(
              fontSize: 12, fontWeight: FontWeight.w600,
            ), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${task.platform.toUpperCase()} • ${task.quality} • ${task.format}',
              style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF6B6B8A))),
            if (task.status == DownloadStatus.downloading)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: LinearPercentIndicator(
                  percent: task.progress,
                  lineHeight: 3,
                  backgroundColor: const Color(0xFF2A2A3E),
                  linearGradient: const LinearGradient(
                    colors: [Color(0xFF7C5CFC), Color(0xFFF472B6)],
                  ),
                  padding: EdgeInsets.zero,
                  barRadius: const Radius.circular(4),
                ),
              ),
          ],
        )),
        const SizedBox(width: 8),
        _buildBadge(task),
      ]),
    ),
  );

  Widget _buildBadge(DownloadTask task) {
    if (task.status == DownloadStatus.completed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF0d2e1e),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text('✓ Done', style: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF34D399),
        )),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1e1535),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(task.statusText, style: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFFA78BFA),
      )),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
    child: Text(title.toUpperCase(), style: GoogleFonts.inter(
      fontSize: 11, fontWeight: FontWeight.w600,
      color: const Color(0xFF6B6B8A), letterSpacing: 0.8,
    )),
  );

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
