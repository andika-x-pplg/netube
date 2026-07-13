import 'package:flutter/material.dart';

class VideoAudioPage extends StatefulWidget {
  const VideoAudioPage({super.key});

  @override
  State<VideoAudioPage> createState() =>
      _VideoAudioPageState();
}

class _VideoAudioPageState
    extends State<VideoAudioPage> {

  bool autoPlay = true;
  bool highQuality = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: const Text(
          "Video & Audio",

          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            _buildSwitch(
              title: "Autoplay",
              value: autoPlay,

              onChanged: (value) {

                setState(() {
                  autoPlay = value;
                });
              },
            ),

            const SizedBox(height: 20),

            _buildSwitch(
              title: "High Quality Video",
              value: highQuality,

              onChanged: (value) {

                setState(() {
                  highQuality = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        children: [

          Expanded(
            child: Text(
              title,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),

          Switch(
            value: value,
            activeColor: Colors.redAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}