import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../chat_provider.dart';

class ChatRoomPage extends StatefulWidget {
  final String id;
  final String name;

  const ChatRoomPage({
    super.key,
    required this.id,
    required this.name,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    globalChatProvider.sendMessage(widget.id, widget.name, text);
    _messageController.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    final initials = words.map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase();
    return initials.length > 2 ? initials.substring(0, 2) : initials;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: globalChatProvider,
      builder: (context, _) {
        final messages = globalChatProvider.getMessagesForChat(widget.id);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/profile');
                }
              },
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    _getInitials(widget.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.name,
                        style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Offline',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.call_outlined, color: AppColors.primary),
                onPressed: () {
                  context.push('/live-call', extra: {
                    'name': widget.name,
                    'image': _getProfileImageForAstrologer(widget.name),
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  side: const BorderSide(color: Color(0x40D4A437)),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.videocam_outlined, color: AppColors.primary),
                onPressed: () {
                  context.push('/video-call', extra: {
                    'name': widget.name,
                    'image': _getProfileImageForAstrologer(widget.name),
                  });
                },
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  side: const BorderSide(color: Color(0x40D4A437)),
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          body: Column(
            children: [
              // Message List
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Text(
                          'Start a conversation with ${widget.name}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
              ),

              // Bottom Input Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // Smiley icon button
                      IconButton(
                        icon: const Icon(Icons.sentiment_satisfied_alt_outlined, color: AppColors.textPrimary),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 4),

                      // Text Field input
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xffF2ECE4)),
                          ),
                          child: TextField(
                            controller: _messageController,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: const InputDecoration(
                              hintText: 'Type a message...',
                              hintStyle: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 14,
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Circular Gold Send Button
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xffE4A834),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xffD4A437).withOpacity(0.85) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.time,
              style: TextStyle(
                color: isMe ? Colors.white70 : AppColors.textLight,
                fontSize: 9,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getProfileImageForAstrologer(String name) {
    if (name.contains('Meera')) return 'assets/images/meera.jpg';
    if (name.contains('Priya')) return 'assets/images/priya.jpg';
    if (name.contains('Shivam')) return 'assets/images/shivam.jpg';
    if (name.contains('Anand')) return 'assets/images/anand.jpg';
    return 'assets/images/logo.png';
  }
}
