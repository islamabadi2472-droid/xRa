// ── VIDEO MODEL ──
class VideoItem {
  final int? id;
  final String title;
  final String filePath;
  final String? thumbnailPath;
  final int? duration; // seconds
  final int? fileSize; // bytes
  final String? source; // youtube, instagram, etc
  final int? playlistId;
  final DateTime addedAt;

  VideoItem({
    this.id,
    required this.title,
    required this.filePath,
    this.thumbnailPath,
    this.duration,
    this.fileSize,
    this.source,
    this.playlistId,
    required this.addedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'filePath': filePath,
    'thumbnailPath': thumbnailPath,
    'duration': duration,
    'fileSize': fileSize,
    'source': source,
    'playlistId': playlistId,
    'addedAt': addedAt.toIso8601String(),
  };

  factory VideoItem.fromMap(Map<String, dynamic> map) => VideoItem(
    id: map['id'],
    title: map['title'],
    filePath: map['filePath'],
    thumbnailPath: map['thumbnailPath'],
    duration: map['duration'],
    fileSize: map['fileSize'],
    source: map['source'],
    playlistId: map['playlistId'],
    addedAt: DateTime.parse(map['addedAt']),
  );

  String get durationFormatted {
    if (duration == null) return '--:--';
    final m = duration! ~/ 60;
    final s = duration! % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get fileSizeFormatted {
    if (fileSize == null) return '';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    if (fileSize! < 1024 * 1024 * 1024) return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize! / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

// ── PLAYLIST MODEL ──
class Playlist {
  final int? id;
  final String name;
  final String? description;
  final bool isLocked;
  final String? pinHash; // SHA-256 hash of PIN
  final bool biometricEnabled;
  final String? coverEmoji;
  final DateTime createdAt;

  Playlist({
    this.id,
    required this.name,
    this.description,
    this.isLocked = false,
    this.pinHash,
    this.biometricEnabled = false,
    this.coverEmoji,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'isLocked': isLocked ? 1 : 0,
    'pinHash': pinHash,
    'biometricEnabled': biometricEnabled ? 1 : 0,
    'coverEmoji': coverEmoji,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Playlist.fromMap(Map<String, dynamic> map) => Playlist(
    id: map['id'],
    name: map['name'],
    description: map['description'],
    isLocked: map['isLocked'] == 1,
    pinHash: map['pinHash'],
    biometricEnabled: map['biometricEnabled'] == 1,
    coverEmoji: map['coverEmoji'],
    createdAt: DateTime.parse(map['createdAt']),
  );

  Playlist copyWith({
    String? name,
    String? description,
    bool? isLocked,
    String? pinHash,
    bool? biometricEnabled,
    String? coverEmoji,
  }) => Playlist(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    isLocked: isLocked ?? this.isLocked,
    pinHash: pinHash ?? this.pinHash,
    biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    coverEmoji: coverEmoji ?? this.coverEmoji,
    createdAt: createdAt,
  );
}

// ── DOWNLOAD TASK MODEL ──
enum DownloadStatus { queued, downloading, paused, completed, failed }

class DownloadTask {
  final String id;
  final String url;
  final String title;
  final String quality;
  final String format; // mp4, mp3
  final String platform;
  DownloadStatus status;
  double progress; // 0.0 to 1.0
  String? filePath;
  String? errorMessage;
  final DateTime startedAt;

  DownloadTask({
    required this.id,
    required this.url,
    required this.title,
    required this.quality,
    required this.format,
    required this.platform,
    this.status = DownloadStatus.queued,
    this.progress = 0.0,
    this.filePath,
    this.errorMessage,
    required this.startedAt,
  });

  String get platformIcon {
    switch (platform.toLowerCase()) {
      case 'youtube': return '📺';
      case 'instagram': return '📸';
      case 'tiktok': return '🎵';
      case 'facebook': return '📘';
      case 'twitter': return '🐦';
      case 'vimeo': return '🎬';
      default: return '🌐';
    }
  }

  String get statusText {
    switch (status) {
      case DownloadStatus.queued: return 'Waiting...';
      case DownloadStatus.downloading: return '${(progress * 100).toInt()}%';
      case DownloadStatus.paused: return 'Paused';
      case DownloadStatus.completed: return 'Done ✓';
      case DownloadStatus.failed: return 'Failed';
    }
  }
}
