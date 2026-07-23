import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class AstrologerChatRoomPage extends StatefulWidget {
  final String id; // astrologerId
  final String name; // Client name
  final String? otherUid; // Client's Firebase UID / Supabase ID
  final String? avatarUrl; // Client avatar URL

  const AstrologerChatRoomPage({
    super.key,
    required this.id,
    required this.name,
    this.otherUid,
    this.avatarUrl,
  });

  @override
  State<AstrologerChatRoomPage> createState() => _AstrologerChatRoomPageState();
}

class _AstrologerChatRoomPageState extends State<AstrologerChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _clientName;
  String? _clientAvatarUrl;
  bool _isUploadingImage = false;
  late ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<ChatBloc>();
    _clientName = widget.name;
    _clientAvatarUrl = widget.avatarUrl;

    final currentAstro = FirebaseAuth.instance.currentUser;
    final currentAstroAvatar = currentAstro?.photoURL;

    // Join chat room in ChatBloc passing targetOtherUid (Client UID)
    _chatBloc.add(
      OpenChatRoomEvent(
        astrologerId: widget.id,
        astrologerName: widget.name,
        targetOtherUid: widget.otherUid,
        userAvatar: _clientAvatarUrl,
        astrologerAvatar: currentAstroAvatar,
      ),
    );

    // Fetch client details if avatar is missing
    _fetchClientDetails();
  }

  Future<void> _fetchClientDetails() async {
    final clientUid = widget.otherUid;
    if (clientUid == null || clientUid.isEmpty) return;

    // Check if clientUid is a valid UUID format before querying profiles table
    final isUuid = clientUid.length == 36 && clientUid.contains('-');
    if (!isUuid) return;

    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', clientUid)
          .maybeSingle();

      if (res != null && mounted) {
        setState(() {
          if (res['full_name'] != null && res['full_name'].toString().isNotEmpty) {
            _clientName = res['full_name'].toString();
          }
          if (res['avatar_url'] != null && res['avatar_url'].toString().isNotEmpty) {
            _clientAvatarUrl = res['avatar_url'].toString();
          }
        });
      }
    } catch (e) {
      debugPrint('[AstrologerChatRoomPage] Error fetching client info: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatBloc.add(CloseChatRoomEvent());
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _chatBloc.add(
      SendMessageEvent(
        astrologerId: widget.id,
        astrologerName: widget.name,
        text: text,
      ),
    );

    _messageController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickAndUploadAttachment() async {
    final picker = image_picker.ImagePicker();
    final pickedFile = await picker.pickImage(
      source: image_picker.ImageSource.gallery,
    );
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final length = await file.length();

    if (length > 5 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image exceeds 5 MB limit.')),
        );
      }
      return;
    }

    final fileExt = pickedFile.path.split('.').last.toLowerCase();
    if (fileExt != 'png' && fileExt != 'jpg' && fileExt != 'jpeg') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only PNG, JPG, and JPEG images are allowed.')),
        );
      }
      return;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final fileName = 'attachments/astrologer/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final supabase = Supabase.instance.client;

      await supabase.storage.from('chat_attachments').upload(fileName, file);
      final signedUrl = await supabase.storage
          .from('chat_attachments')
          .createSignedUrl(fileName, 604800);

      _chatBloc.add(
        SendMessageEvent(
          astrologerId: widget.id,
          astrologerName: widget.name,
          text: '',
          imageUrl: signedUrl,
        ),
      );
    } catch (e) {
      debugPrint('[AstrologerChatRoomPage] Error uploading attachment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  void _startCall({required bool isVideo}) {
    final route = isVideo ? '/video-call' : '/live-call';
    final clientDisplayName = (_clientName != null && _clientName!.isNotEmpty)
        ? _clientName!
        : widget.name;
    final extra = {
      'id': widget.otherUid ?? widget.id,
      'name': clientDisplayName,
      'firebase_uid': widget.otherUid ?? '',
      'image': _clientAvatarUrl ?? widget.avatarUrl ?? '',
      'avatar_url': _clientAvatarUrl ?? widget.avatarUrl ?? '',
      'call_rate': 0.0,
      'video_rate': 0.0,
      'astrologer': {
        'id': widget.id,
        'name': clientDisplayName,
        'avatar_url': _clientAvatarUrl ?? widget.avatarUrl ?? '',
        'image': _clientAvatarUrl ?? widget.avatarUrl ?? '',
        'firebase_uid': widget.otherUid ?? '',
        'call_rate': 0.0,
        'video_rate': 0.0,
      }
    };
    context.push(route, extra: extra);
  }

  @override
  Widget build(BuildContext context) {
    final displayName = (_clientName != null && _clientName!.isNotEmpty)
        ? _clientName!
        : 'Client';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFFDF6EC),
              backgroundImage: (_clientAvatarUrl != null && _clientAvatarUrl!.isNotEmpty)
                  ? NetworkImage(_clientAvatarUrl!)
                  : null,
              child: (_clientAvatarUrl == null || _clientAvatarUrl!.isEmpty)
                  ? Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'Client Chat',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Color(0xFFD4AF37)),
            tooltip: 'Audio Call',
            onPressed: () => _startCall(isVideo: false),
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: Color(0xFFD4AF37)),
            tooltip: 'Video Call',
            onPressed: () => _startCall(isVideo: true),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages Stream
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  List<ChatMessage> messages = [];
                  if (state is ChatUpdatedState) {
                    final activeRoomId = state.activeRoomId;
                    if (activeRoomId != null &&
                        state.messages.containsKey(activeRoomId)) {
                      messages = state.messages[activeRoomId]!;
                    } else {
                      messages = (widget.otherUid != null
                              ? state.messages[widget.otherUid!]
                              : null) ??
                          state.messages[widget.id] ??
                          [];
                    }
                  }

                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'Start conversation with $displayName',
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(messages[index]);
                    },
                  );
                },
              ),
            ),

            // Input Bar
            Container(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 8,
                bottom: MediaQuery.of(context).padding.bottom + 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_isUploadingImage)
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    )
                  else
                    IconButton(
                      icon: const Icon(
                        Icons.add_photo_alternate_rounded,
                        color: Color(0xFFD4AF37),
                        size: 26,
                      ),
                      onPressed: _pickAndUploadAttachment,
                      tooltip: 'Send Image (Free)',
                    ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Type your message to $displayName...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: const Color(0xFFD4AF37),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _sendMessage,
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.isMe;

    if (message.text.startsWith('[CALL_LOG]:')) {
      final parts = message.text.split(':');
      final mode = parts.length > 1 ? parts[1] : 'audio';
      final status = parts.length > 2 ? parts[2] : 'ended';

      final isVoice = mode == 'audio';
      final isMissed = status == 'missed';

      IconData callIcon = isVoice
          ? (isMissed
                ? (isMe
                      ? Icons.phone_callback_rounded
                      : Icons.phone_missed_rounded)
                : (isMe
                      ? Icons.phone_forwarded_rounded
                      : Icons.phone_callback_rounded))
          : (isMissed
                ? (isMe
                      ? Icons.missed_video_call_rounded
                      : Icons.missed_video_call_rounded)
                : (isMe
                      ? Icons.video_camera_back_rounded
                      : Icons.videocam_rounded));

      Color iconColor = isMissed ? Colors.redAccent : const Color(0xFF10B981);

      String title = isVoice ? 'Voice Call' : 'Video Call';
      String subtitle = isMe ? 'Outgoing' : (isMissed ? 'Missed' : 'Incoming');

      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBF2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFF0D4), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(callIcon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          color: isMissed ? Colors.redAccent : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•  ${message.time}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFD4AF37) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  message.imageUrl!,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            if (message.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 15,
                  ),
                ),
              ),
            const SizedBox(height: 2),
            Text(
              message.time,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
