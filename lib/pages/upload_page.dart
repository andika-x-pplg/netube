import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/local_video_duration.dart';
import '../services/netube_content_service.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/library_widgets.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  static const _categories = [
    'Music',
    'Gaming',
    'Live',
    'Movies',
    'Anime',
    'Shorts',
    'Entertainment',
    'Education',
  ];
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  XFile? _thumbnail;
  XFile? _video;
  Duration? _videoDuration;
  Uint8List? _thumbnailPreview;
  String _selectedCategory = _categories.first;
  String _visibility = 'public';
  bool _uploading = false;
  double _progress = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );
    if (file == null) return;
    final preview = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _thumbnail = file;
      _thumbnailPreview = preview;
    });
  }

  Future<void> _pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null || !mounted) return;
    try {
      final duration = await readLocalVideoDuration(file);
      if (!mounted) return;
      setState(() {
        _video = file;
        _videoDuration = duration;
        if (duration <= const Duration(minutes: 3)) {
          _selectedCategory = 'Shorts';
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video tidak dapat dibaca. Pilih file video lain.'),
        ),
      );
    }
  }

  String _extension(XFile file, String fallback) {
    final parts = file.name.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : fallback;
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_thumbnail == null || _video == null || _videoDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a thumbnail and video first.')),
      );
      return;
    }
    setState(() {
      _uploading = true;
      _progress = 0;
    });
    try {
      await NetubeContentService.upload(
        thumbnailFile: _thumbnail!,
        thumbnailExtension: _extension(_thumbnail!, 'jpg'),
        videoFile: _video!,
        videoExtension: _extension(_video!, 'mp4'),
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        visibility: _visibility,
        duration: _videoDuration!,
        onProgress: (value) {
          if (mounted) setState(() => _progress = value);
        },
      );
      if (!mounted) return;
      _formKey.currentState!.reset();
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _thumbnail = null;
        _video = null;
        _videoDuration = null;
        _thumbnailPreview = null;
        _progress = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content uploaded to Netube.')),
      );
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_firebaseUploadMessage(error))));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload gagal: $error')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  String _firebaseUploadMessage(FirebaseException error) {
    switch (error.code) {
      case 'unauthorized':
        return 'Upload ditolak. Periksa izin Firebase Storage akun ini.';
      case 'canceled':
        return 'Upload dibatalkan.';
      case 'quota-exceeded':
        return 'Kuota Firebase Storage sudah habis.';
      case 'retry-limit-exceeded':
        return 'Koneksi upload terputus. Periksa internet lalu coba lagi.';
      default:
        return 'Upload gagal (${error.code}): ${error.message ?? 'coba lagi'}';
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: libraryBackground,
    appBar: AppBar(
      backgroundColor: libraryBackground,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: const Text(
        'Upload Content',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    ),
    bottomNavigationBar: const BottomNavbar(currentIndex: 3),
    body: SafeArea(
      top: false,
      child: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
          children: [
            const LibraryHeader(
              title: 'Create on Netube',
              description: 'Share your own videos with the Netube community.',
              icon: Icons.cloud_upload_rounded,
            ),
            const SizedBox(height: 24),
            _MediaPicker(
              title: 'Thumbnail',
              subtitle: _thumbnail?.name ?? 'Choose a cinematic cover image',
              icon: Icons.add_photo_alternate_rounded,
              onTap: _uploading ? null : _pickThumbnail,
              preview: _thumbnailPreview,
              aspectRatio: 16 / 9,
            ),
            const SizedBox(height: 14),
            _MediaPicker(
              title: 'Video file',
              subtitle: _video?.name ?? 'Choose a video from your device',
              icon: Icons.video_file_rounded,
              onTap: _uploading ? null : _pickVideo,
            ),
            const SizedBox(height: 24),
            _label('Content details'),
            const SizedBox(height: 12),
            _field(
              controller: _titleController,
              label: 'Title',
              hint: 'Give your video a clear title',
              maxLength: 100,
            ),
            const SizedBox(height: 14),
            _field(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Tell viewers about your video',
              maxLines: 5,
              maxLength: 1000,
            ),
            const SizedBox(height: 22),
            _label('Category'),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              dropdownColor: const Color(0xFF111827),
              decoration: _inputDecoration('Select category'),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: _uploading
                  ? null
                  : (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 22),
            _label('Visibility'),
            const SizedBox(height: 10),
            ...[
              (
                'public',
                'Public',
                'Everyone on Netube can watch',
                Icons.public_rounded,
              ),
              ('private', 'Private', 'Only you can watch', Icons.lock_rounded),
              (
                'archived',
                'Archive',
                'Hidden and only visible to you',
                Icons.archive_rounded,
              ),
            ].map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _VisibilityOption(
                  value: option.$1,
                  title: option.$2,
                  description: option.$3,
                  icon: option.$4,
                  selected: _visibility == option.$1,
                  onTap: _uploading
                      ? null
                      : () => setState(() => _visibility = option.$1),
                ),
              ),
            ),
            if (_uploading) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progress == 0 ? null : _progress,
                  minHeight: 7,
                  color: libraryAccent,
                  backgroundColor: Colors.white10,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _progress == 0
                    ? 'Preparing upload...'
                    : 'Uploading ${(_progress * 100).round()}%',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: _uploading ? null : _upload,
                style: FilledButton.styleFrom(
                  backgroundColor: libraryAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.cloud_upload_rounded),
                label: Text(
                  _uploading ? 'Uploading...' : 'Upload to Netube',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 17,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    int? maxLength,
  }) => TextFormField(
    controller: controller,
    maxLines: maxLines,
    maxLength: maxLength,
    style: const TextStyle(color: Colors.white),
    validator: (value) =>
        value == null || value.trim().isEmpty ? '$label is required' : null,
    decoration: _inputDecoration(hint).copyWith(labelText: label),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white30),
    labelStyle: const TextStyle(color: Colors.white54),
    filled: true,
    fillColor: const Color(0xFF111827),
    counterStyle: const TextStyle(color: Colors.white38),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: .06)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: libraryAccent),
    ),
  );
}

class _MediaPicker extends StatelessWidget {
  const _MediaPicker({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.preview,
    this.aspectRatio,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Uint8List? preview;
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFF111827),
    borderRadius: BorderRadius.circular(20),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: preview != null
          ? AspectRatio(
              aspectRatio: aspectRatio ?? 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(preview!, fit: BoxFit.cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC050B18)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 14,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: .06)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: libraryAccent.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: libraryAccent),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .46),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white30,
                  ),
                ],
              ),
            ),
    ),
  );
}

class _VisibilityOption extends StatelessWidget {
  const _VisibilityOption({
    required this.value,
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String value;
  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFF24151C) : const Color(0xFF111827),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? libraryAccent.withValues(alpha: .55)
                : Colors.white.withValues(alpha: .05),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? libraryAccent : Colors.white54),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .46),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? libraryAccent : Colors.white38,
            ),
          ],
        ),
      ),
    ),
  );
}
