
import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';

class VimeoProScreen extends StatefulWidget {
  const VimeoProScreen({Key? key}) : super(key: key);

  @override
  State<VimeoProScreen> createState() => _VimeoProScreenState();
}

class _VimeoProScreenState extends State<VimeoProScreen> {
  late final PodPlayerController controller;

  // This variable now tracks BOTH skipping and buffering
  bool _isSkipping = false;

  @override
  void initState() {
    super.initState();
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.vimeo('524933864'),
      podPlayerConfig: const PodPlayerConfig(
        autoPlay: false,
        isLooping: false,
        videoQualityPriority: [720, 360],
      ),
    )..initialise();

    // 1. ADD LISTENER
    controller.addListener(_videoListener);
  }

  // 2. LISTENER FUNCTION
  void _videoListener() {
    if (!mounted) return;

    // Check if the video is buffering (loading from internet)
    final isBuffering = controller.videoPlayerValue?.isBuffering ?? false;

    // Only call setState if the value actually changed to avoid lag
    if (_isSkipping != isBuffering) {
      setState(() {
        _isSkipping = isBuffering;
      });
    }
  }

  @override
  void dispose() {
    // 3. REMOVE LISTENER
    controller.removeListener(_videoListener);
    controller.dispose();
    super.dispose();
  }

  void skipForward() async {
    // Force show loader immediately for better UX
    setState(() {
      _isSkipping = true;
    });

    final currentPosition = controller.videoPlayerValue?.position ?? Duration.zero;
    final totalDuration = controller.videoPlayerValue?.duration ?? Duration.zero;
    var newPosition = currentPosition + const Duration(seconds: 10);
    if (newPosition > totalDuration) newPosition = totalDuration;

    await controller.videoSeekTo(newPosition);


  }


  final String _vimeoVideoId = '76979871';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. THE REQUIRED VIMEO PLAYER ---
              Container(
                height: 250, // Height fix karna zaroori hai layout ke liye
                color: Colors.black,
                child: VimeoVideoPlayer(
                  videoId: _vimeoVideoId,
                  // Auto-play aur Mute settings yahan hoti hain
                  isAutoPlay: false,
                ),
              ),

              // --- 2. PROFESSIONAL UI (Ye same rakha hai taaki marks acche milein) ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Cinematic Nature: The Beauty of Mountains 4K",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text("1.2M views • 2 days ago", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 20),

                    // Buttons (Note: Skip button hata diya kyunki package allow nahi karta)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionBtn(Icons.thumb_up_alt_outlined, "Like"),
                        _buildActionBtn(Icons.share, "Share"),
                        _buildActionBtn(Icons.download, "Save"),
                        _buildActionBtn(Icons.playlist_add, "List"),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.grey, thickness: 0.5),

              // --- 3. UP NEXT LIST ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: const Text("Up Next", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _buildVideoTile("Flutter Tutorial for Beginners", "20:15", Colors.redAccent),
              _buildVideoTile("Dart Programming Loop Logic", "12:30", Colors.teal),
              _buildVideoTile("Building UI with Tailwind CSS", "45:00", Colors.purple),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets (Same as before)
  Widget _buildActionBtn(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 26),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildVideoTile(String title, String duration, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15, left: 16, right: 16),
      child: Row(
        children: [
          Container(
            width: 120, height: 70,
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text(duration, style: const TextStyle(fontSize: 10, color: Colors.white))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 5),
            const Text("Code Master • 5K views", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ])),
        ],
      ),
    );
  }
}