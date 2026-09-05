import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

Future<TaskSnapshot> uploadXFile(
  Reference reference,
  XFile file,
  String contentType, {
  void Function(double progress)? onProgress,
}) async {
  final task = reference.putFile(
    File(file.path),
    SettableMetadata(contentType: contentType),
  );
  final subscription = task.snapshotEvents.listen((snapshot) {
    if (snapshot.totalBytes > 0) {
      onProgress?.call(snapshot.bytesTransferred / snapshot.totalBytes);
    }
  });
  try {
    return await task;
  } finally {
    await subscription.cancel();
  }
}
