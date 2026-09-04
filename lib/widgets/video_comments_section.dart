import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/video_comment_service.dart';
import 'library_widgets.dart';

class VideoCommentsSection extends StatefulWidget {
  const VideoCommentsSection({super.key, required this.videoId});
  final String videoId;

  @override
  State<VideoCommentsSection> createState() => _VideoCommentsSectionState();
}

class _VideoCommentsSectionState extends State<VideoCommentsSection> {
  final TextEditingController _controller = TextEditingController();
  final Set<String> _expanded = {};
  final Set<String> _showAll = {};
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _commentsStream;
  String _sort = 'Top comments';
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _commentsStream = VideoCommentService.comments(widget.videoId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await VideoCommentService.add(videoId: widget.videoId, text: text);
      _controller.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _commentsStream,
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs.toList() ?? [];
        final children =
            <String?, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
        for (final doc in docs) {
          final parentId = doc.data()['parentId'] as String?;
          children.putIfAbsent(parentId, () => []).add(doc);
        }
        final roots = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
          children[null] ?? const [],
        );
        if (_sort == 'Top comments') {
          roots.sort((a, b) {
            final likesA = (a.data()['likeCount'] as num?)?.toInt() ?? 0;
            final likesB = (b.data()['likeCount'] as num?)?.toInt() ?? 0;
            final likeOrder = likesB.compareTo(likesA);
            return likeOrder != 0 ? likeOrder : _date(b).compareTo(_date(a));
          });
        } else {
          roots.sort((a, b) => _date(b).compareTo(_date(a)));
        }
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          decoration: BoxDecoration(
            color: librarySurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: .06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Comments',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    initialValue: _sort,
                    color: const Color(0xFF182233),
                    onSelected: (value) => setState(() => _sort = value),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'Top comments',
                        child: Text('Top comments'),
                      ),
                      PopupMenuItem(value: 'Newest', child: Text('Newest')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sort_rounded,
                            color: Colors.white54,
                            size: 17,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _sort,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Composer(
                controller: _controller,
                sending: _sending,
                onSend: _send,
              ),
              const SizedBox(height: 20),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.3,
                      color: libraryAccent,
                    ),
                  ),
                )
              else if (roots.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 26),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          color: Colors.white24,
                          size: 32,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No comments yet',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Start the conversation.',
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...roots.map((doc) => _comment(doc, children, 0)),
            ],
          ),
        );
      },
    );
  }

  Widget _comment(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    Map<String?, List<QueryDocumentSnapshot<Map<String, dynamic>>>> children,
    int depth, {
    bool forceExpanded = false,
  }) {
    final data = doc.data();
    final replies = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
      children[doc.id] ?? const [],
    );
    replies.sort((a, b) => _date(a).compareTo(_date(b)));
    final expanded = forceExpanded || _expanded.contains(doc.id);
    final showAll = _showAll.contains(doc.id);
    final replyCount = _descendantCount(doc.id, children);
    final firstReplies = forceExpanded ? replies : replies.take(5).toList();
    final additionalReplies = showAll ? replies.skip(5).toList() : const [];
    return Padding(
      padding: EdgeInsets.only(left: depth == 0 ? 0 : 12, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommentTile(
            videoId: widget.videoId,
            commentId: doc.id,
            data: data,
            onReply: () => _showEditor(
              parentId: doc.id,
              replyTo: data['username']?.toString(),
            ),
            onEdit: VideoCommentService.canEdit(data)
                ? () => _showEditor(
                    commentId: doc.id,
                    initialText: data['text']?.toString(),
                  )
                : null,
            onDelete: data['uid'] == VideoCommentService.currentUid
                ? () => _delete(doc.id)
                : null,
          ),
          if (replies.isNotEmpty && !forceExpanded)
            TextButton.icon(
              onPressed: () => setState(
                () =>
                    expanded ? _expanded.remove(doc.id) : _expanded.add(doc.id),
              ),
              icon: Icon(
                expanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 19,
              ),
              label: Text(
                expanded
                    ? 'Hide replies'
                    : '$replyCount ${replyCount == 1 ? 'reply' : 'replies'}',
              ),
            ),
          if (expanded) ...[
            ...firstReplies.map(
              (reply) =>
                  _comment(reply, children, depth + 1, forceExpanded: true),
            ),
            if (!forceExpanded && replies.length > 5)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: TextButton(
                  onPressed: () => setState(() {
                    if (showAll) {
                      _showAll.remove(doc.id);
                    } else {
                      _showAll.add(doc.id);
                    }
                  }),
                  child: Text(
                    showAll
                        ? 'Hide replies'
                        : 'See ${replies.length - 5} more replies',
                  ),
                ),
              ),
            ...additionalReplies.map(
              (reply) =>
                  _comment(reply, children, depth + 1, forceExpanded: true),
            ),
          ],
        ],
      ),
    );
  }

  int _descendantCount(
    String parentId,
    Map<String?, List<QueryDocumentSnapshot<Map<String, dynamic>>>> children,
  ) {
    final directReplies = children[parentId] ?? const [];
    var total = directReplies.length;
    for (final reply in directReplies) {
      total += _descendantCount(reply.id, children);
    }
    return total;
  }

  Future<void> _showEditor({
    String? parentId,
    String? replyTo,
    String? commentId,
    String? initialText,
  }) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _CommentEditorSheet(
        title: commentId != null
            ? 'Edit comment'
            : 'Reply to ${replyTo ?? 'comment'}',
        actionLabel: commentId != null ? 'Save' : 'Reply',
        initialText: initialText ?? '',
      ),
    );
    if (!mounted) return;
    if (result == null || result.isEmpty) return;
    if (commentId != null) {
      await VideoCommentService.edit(
        videoId: widget.videoId,
        commentId: commentId,
        text: result,
      );
    } else {
      await VideoCommentService.add(
        videoId: widget.videoId,
        text: result,
        parentId: parentId,
      );
      if (parentId != null && mounted) setState(() => _expanded.add(parentId));
    }
  }

  Future<void> _delete(String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        title: const Text(
          'Delete comment?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: libraryAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await VideoCommentService.delete(
        videoId: widget.videoId,
        commentId: commentId,
      );
    }
  }
}

class _CommentEditorSheet extends StatefulWidget {
  const _CommentEditorSheet({
    required this.title,
    required this.actionLabel,
    required this.initialText,
  });

  final String title;
  final String actionLabel;
  final String initialText;

  @override
  State<_CommentEditorSheet> createState() => _CommentEditorSheetState();
}

class _CommentEditorSheetState extends State<_CommentEditorSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        18,
        18,
        MediaQuery.viewInsetsOf(context).bottom + 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            autofocus: true,
            minLines: 1,
            maxLines: 5,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Write your comment...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: libraryBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, _controller.text.trim()),
              style: FilledButton.styleFrom(backgroundColor: libraryAccent),
              child: Text(widget.actionLabel),
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      _Avatar(name: VideoCommentService.currentUid, size: 36),
      const SizedBox(width: 10),
      Expanded(
        child: TextField(
          controller: controller,
          minLines: 1,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Add a comment...',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: libraryBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      IconButton.filled(
        onPressed: sending ? null : onSend,
        style: IconButton.styleFrom(backgroundColor: libraryAccent),
        icon: sending
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send_rounded, size: 19),
      ),
    ],
  );
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.videoId,
    required this.commentId,
    required this.data,
    required this.onReply,
    this.onEdit,
    this.onDelete,
  });
  final String videoId;
  final String commentId;
  final Map<String, dynamic> data;
  final VoidCallback onReply;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final owner = data['uid'] == VideoCommentService.currentUid;
    final name = data['username']?.toString() ?? 'User';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(name: name, size: 34),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      owner ? '$name • You' : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    _relativeTime(data['createdAt']),
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  if (data['updatedAt'] != null)
                    const Text(
                      ' • edited',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  if (onDelete != null) ...[
                    const Spacer(),
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      color: const Color(0xFF182233),
                      iconColor: Colors.white54,
                      onSelected: (value) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (value == 'edit') {
                            onEdit?.call();
                          } else {
                            onDelete?.call();
                          }
                        });
                      },
                      itemBuilder: (_) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 5),
              Text(
                data['text']?.toString() ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  height: 1.4,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 7),
              StreamBuilder<String?>(
                stream: VideoCommentService.myReaction(videoId, commentId),
                builder: (context, snapshot) {
                  final reaction = snapshot.data;
                  return Wrap(
                    spacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _ReactionButton(
                        icon: reaction == 'like'
                            ? Icons.thumb_up_rounded
                            : Icons.thumb_up_outlined,
                        count: (data['likeCount'] as num?)?.toInt() ?? 0,
                        active: reaction == 'like',
                        onTap: () => VideoCommentService.toggleReaction(
                          videoId: videoId,
                          commentId: commentId,
                          reaction: 'like',
                        ),
                      ),
                      if (!owner)
                        _ReactionButton(
                          icon: reaction == 'dislike'
                              ? Icons.thumb_down_rounded
                              : Icons.thumb_down_outlined,
                          count: (data['dislikeCount'] as num?)?.toInt() ?? 0,
                          active: reaction == 'dislike',
                          onTap: () => VideoCommentService.toggleReaction(
                            videoId: videoId,
                            commentId: commentId,
                            reaction: 'dislike',
                          ),
                        ),
                      TextButton(
                        onPressed: onReply,
                        child: const Text(
                          'Reply',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReactionButton extends StatelessWidget {
  const _ReactionButton({
    required this.icon,
    required this.count,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final int count;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: active ? libraryAccent : Colors.white54),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                color: active ? libraryAccent : Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.size});
  final String name;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(colors: [Color(0xFFFF493E), Color(0xFF8F1720)]),
    ),
    child: Text(
      name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase(),
      style: TextStyle(
        color: Colors.white,
        fontSize: size * .4,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

DateTime _date(QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
    (doc.data()['createdAt'] as Timestamp?)?.toDate() ??
    DateTime.fromMillisecondsSinceEpoch(0);

String _relativeTime(dynamic value) {
  if (value is! Timestamp) return 'now';
  final difference = DateTime.now().difference(value.toDate());
  if (difference.inSeconds < 60) {
    return '${difference.inSeconds.clamp(0, 59)}s ago';
  }
  if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
  if (difference.inHours < 24) return '${difference.inHours}h ago';
  if (difference.inDays < 7) return '${difference.inDays}d ago';
  if (difference.inDays < 30) return '${difference.inDays ~/ 7}w ago';
  if (difference.inDays < 365) return '${difference.inDays ~/ 30}mo ago';
  return '${difference.inDays ~/ 365}y ago';
}
