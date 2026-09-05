import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

Future<Duration> readLocalVideoDuration(XFile file) async {
  final controller = VideoPlayerController.networkUrl(Uri.parse(file.path));
  try {
    await controller.initialize();
    return controller.value.duration;
  } finally {
    await controller.dispose();
  }
}
