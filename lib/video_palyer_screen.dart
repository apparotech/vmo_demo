
import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';

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

    // We don't need to manually set false here anymore,
    // the _videoListener will handle it when buffering finishes!
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // VIDEO PLAYER STACK
              Stack(
                alignment: Alignment.center,
                children: [
                  PodVideoPlayer(
                    controller: controller,
                    frameAspectRatio: 16 / 9,
                    alwaysShowProgressBar: true,
                    // Important: Hide default loader so we only see YOUR custom round loader
                    onLoading: (context) => const SizedBox(),
                  ),

                  // THE MAGIC: Round Progress Bar Overlay
                  if (_isSkipping)
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: const [
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                          // Only show text if we are manually skipping, otherwise just show loader
                          Icon(Icons.play_arrow, color: Colors.white, size: 20)
                        ],
                      ),
                    ),
                ],
              ),

              // INFO SECTION
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

                    // CONTROLS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionBtn(Icons.thumb_up_alt_outlined, "Like"),
                        _buildActionBtn(Icons.share, "Share"),
                        _buildActionBtn(Icons.download, "Save"),

                        // Custom Skip Button
                        InkWell(
                          onTap: _isSkipping ? null : skipForward,
                          borderRadius: BorderRadius.circular(30),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: _isSkipping ? Colors.white10 : Colors.blueAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: _isSkipping ? Colors.grey : Colors.blueAccent
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                    _isSkipping ? "Loading..." : "+10s",
                                    style: TextStyle(
                                        color: _isSkipping ? Colors.grey : Colors.blueAccent,
                                        fontWeight: FontWeight.bold
                                    )
                                ),
                                if (!_isSkipping)
                                  const Icon(Icons.forward_10, color: Colors.blueAccent, size: 20),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.grey, thickness: 0.5),

              // LIST
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                child: const Text("Up Next", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              _buildVideoTile("Flutter Tutorial for Beginners", "20:15", Colors.redAccent),
              _buildVideoTile("Dart Programming Loop Logic", "12:30", Colors.teal),
            ],
          ),
        ),
      ),
    );
  }

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