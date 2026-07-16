import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../../astrologers/bloc/astrologers_bloc.dart';
import '../../astrologers/bloc/astrologers_state.dart';
import '../../wallet/bloc/wallet_bloc.dart';
import '../../wallet/bloc/wallet_event.dart';
import '../../wallet/bloc/wallet_state.dart';
import '../../reviews/widgets/write_review_bottom_sheet.dart';
import '../../../app/route.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';

class ChatRoomPage extends StatefulWidget {
  final String id;
  final String name;
  final String? otherUid;
  final String? avatarUrl;

  const ChatRoomPage({
    super.key,
    required this.id,
    required this.name,
    this.otherUid,
    this.avatarUrl,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatBloc _chatBloc;
  int _charCount = 0;
  int _remainingCharacters = 0;
  String? _pendingMessageText;
  String? _firebaseUid;
  String? _pendingCallRoute;
  Map<String, dynamic>? _pendingCallExtra;
  double _callRate = 10.0;
  double _videoRate = 15.0;

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<ChatBloc>();
    _messageController.addListener(_onTextChanged);

    // Fetch astrologer's firebase_uid if available, otherwise trust the provided otherUid
    final astroState = context.read<AstrologersBloc>().state;
    _firebaseUid = widget.otherUid;
    if ((_firebaseUid == null || _firebaseUid!.isEmpty) &&
        astroState is AstrologersFollowingState) {
      try {
        final astro = astroState.astrologers.firstWhere(
          (a) => a['id']?.toString() == widget.id.toString(),
        );
        if (astro['firebase_uid'] != null &&
            astro['firebase_uid'].toString().isNotEmpty) {
          _firebaseUid = astro['firebase_uid']?.toString();
        }
      } catch (_) {}
    }

    _callRate = _readRateFromAstrologerState('call_rate', 10.0);
    _videoRate = _readRateFromAstrologerState('video_rate', 15.0);

    // Initialize chat room listening
    final authState = context.read<AuthBloc>().state;
    final isAstrologer =
        authState is AuthenticatedAsAstrologer ||
        authState is AstrologerOnboardingRequired;

    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserAvatar = currentUser?.photoURL;

    String? userAv;
    String? astroAv;
    if (isAstrologer) {
      userAv = widget.avatarUrl;
      astroAv = currentUserAvatar;
    } else {
      userAv = currentUserAvatar;
      astroAv = widget.avatarUrl;
    }

    _chatBloc.add(
      OpenChatRoomEvent(
        astrologerId: widget.id,
        astrologerName: widget.name,
        astrologerFirebaseUid: _firebaseUid,
        userAvatar: userAv,
        astrologerAvatar: astroAv,
      ),
    );

    final currentState = _chatBloc.state;
    if (currentState is ChatUpdatedState) {
      _remainingCharacters = currentState.remainingCharacters[widget.id] ?? 0;
    }
  }

  double _readRateFromAstrologerState(String key, double fallback) {
    final astroState = context.read<AstrologersBloc>().state;
    if (astroState is AstrologersFollowingState) {
      try {
        final astro = astroState.astrologers.firstWhere(
          (a) => a['id']?.toString() == widget.id.toString(),
        );
        final value = astro[key];
        if (value is num) {
          return value.toDouble();
        }
      } catch (_) {}
    }
    return fallback;
  }

  void _onTextChanged() {
    if (_messageController.text.length > 160) {
      _messageController.text = _messageController.text.substring(0, 160);
      _messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: _messageController.text.length),
      );
    }
    setState(() {
      _charCount = _messageController.text.length;
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _chatBloc.add(CloseChatRoomEvent());
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authState = context.read<AuthBloc>().state;
    final isAstrologer =
        authState is AuthenticatedAsAstrologer ||
        authState is AstrologerOnboardingRequired;

    if (isAstrologer) {
      // Astrologers send message directly without billing or wallet deduction
      context.read<ChatBloc>().add(
        SendMessageEvent(
          astrologerId: widget.id,
          astrologerName: widget.name,
          text: text,
        ),
      );
      _messageController.clear();
    } else {
      if (_remainingCharacters >= text.length) {
        setState(() {
          _remainingCharacters -= text.length;
        });
        context.read<ChatBloc>().add(
          UpdateRemainingCharactersEvent(
            astrologerId: widget.id,
            characters: _remainingCharacters,
          ),
        );
        context.read<ChatBloc>().add(
          SendMessageEvent(
            astrologerId: widget.id,
            astrologerName: widget.name,
            text: text,
          ),
        );
        _messageController.clear();
      } else {
        _showBillingConfirmationDialog(text);
      }
    }
  }

  void _showBillingConfirmationDialog(String text) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Token Depleted'),
          content: const Text(
            'You have run out of character tokens. Buy a 160-character token for ₹5 to continue, or end the conversation?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                _endConversation();
              },
              child: const Text(
                'End Chat',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                setState(() {
                  _pendingMessageText = text;
                });
                context.read<WalletBloc>().add(
                  DeductForChat(amount: 5.0, astrologerId: widget.id),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
              ),
              child: const Text('Buy Token (₹5)'),
            ),
          ],
        );
      },
    );
  }

  void _endConversation() {
    // Leave chat room
    context.pop();

    // Show review sheet with support for astrologerId
    showModalBottomSheet(
      context: rootNavigatorKey.currentContext ?? context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WriteReviewBottomSheet(
        astrologerId: widget.id,
        astrologerName: widget.name,
      ),
    );
  }

  void _showInsufficientBalanceDialog(
    double balance, {
    double? requiredAmount,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Insufficient Balance'),
          content: Text(
            'Your current balance is ₹${balance.toStringAsFixed(2)}. You need at least ₹${(requiredAmount ?? 5.0).toStringAsFixed(2)} to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/wallet');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
              ),
              child: const Text('Add Money'),
            ),
          ],
        );
      },
    );
  }

  void _confirmAndStartCall({required bool isVideo}) {
    final rate = isVideo ? _videoRate : _callRate;
    final route = isVideo ? '/video-call' : '/live-call';
    final extra = {
      'id': widget.id,
      'name': widget.name,
      'firebase_uid': _firebaseUid,
      'image': widget.avatarUrl ?? '',
    };

    final authState = context.read<AuthBloc>().state;
    final isAstrologer =
        authState is AuthenticatedAsAstrologer ||
        authState is AstrologerOnboardingRequired;

    if (isAstrologer) {
      // Astrologers can initiate calls without wallet checks
      context.push(route, extra: extra);
      return;
    }

    final walletState = context.read<WalletBloc>().state;
    if (walletState is WalletBalanceUpdated && walletState.balance < rate) {
      _showInsufficientBalanceDialog(walletState.balance, requiredAmount: rate);
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Billing'),
          content: Text(
            'This ${isVideo ? 'video' : 'voice'} call will cost ₹${rate.toStringAsFixed(0)} per minute. Continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _pendingCallRoute = route;
                _pendingCallExtra = extra;
                context.read<WalletBloc>().add(
                  DeductMoney(
                    rate,
                    astrologerId: widget.id,
                    astrologerName: widget.name,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
              ),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    final initials = words
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();
    return initials.length > 2 ? initials.substring(0, 2) : initials;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is WalletDeductionSuccess) {
          if (_pendingMessageText != null && _pendingMessageText!.isNotEmpty) {
            setState(() {
              _remainingCharacters += 160;
              _remainingCharacters -= _pendingMessageText!.length;
            });
            context.read<ChatBloc>().add(
              UpdateRemainingCharactersEvent(
                astrologerId: widget.id,
                characters: _remainingCharacters,
              ),
            );
            context.read<ChatBloc>().add(
              SendMessageEvent(
                astrologerId: widget.id,
                astrologerName: widget.name,
                text: _pendingMessageText!,
              ),
            );
            _messageController.clear();
            _pendingMessageText = null;
          } else if (_pendingCallRoute != null && _pendingCallExtra != null) {
            final route = _pendingCallRoute!;
            final extra = _pendingCallExtra!;
            _pendingCallRoute = null;
            _pendingCallExtra = null;
            context.push(route, extra: extra);
          }
        } else if (state is WalletInsufficientBalance) {
          _pendingMessageText = null;
          _showInsufficientBalanceDialog(
            state.currentBalance,
            requiredAmount: state.requiredAmount,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFBF7),
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFFDF9), Color(0xFFF7F2E9)],
                  ),
                ),
              ),
            ),

            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildGlassHeader(context),

                  Expanded(
                    child: BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        List<ChatMessage> messages = [];
                        if (state is ChatUpdatedState) {
                          messages = state.messages[widget.id] ?? [];
                        }

                        if (messages.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 40,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 14),
                                  child: Text(
                                    'Tokens: $_remainingCharacters | $_charCount/160',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _charCount >= 160
                                          ? Colors.redAccent
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Start a conversation with\n${widget.name}',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            return _buildMessageBubble(messages[index]);
                          },
                        );
                      },
                    ),
                  ),

                  _buildPremiumInputBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassHeader(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isAstrologer =
        authState is AuthenticatedAsAstrologer ||
        authState is AstrologerOnboardingRequired;

    return BlocBuilder<AstrologersBloc, AstrologersState>(
      builder: (context, astroState) {
        String? avatarUrl = widget.avatarUrl;
        if ((avatarUrl == null || avatarUrl.isEmpty) &&
            astroState is AstrologersFollowingState) {
          try {
            final astro = astroState.astrologers.firstWhere(
              (a) => a['id'] == widget.id,
            );
            avatarUrl = astro['avatar_url'];
          } catch (_) {}
        }

        return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 12,
                left: 8,
                right: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage:
                          (avatarUrl != null && avatarUrl.isNotEmpty)
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: (avatarUrl == null || avatarUrl.isEmpty)
                          ? Text(
                              _getInitials(widget.name),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: AppTextStyles.headingSmall.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAstrologer ? 'Online' : 'Online · ₹5/msg',
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildHeaderActionButton(Icons.call_rounded, () {
                    _confirmAndStartCall(isVideo: false);
                  }),
                  const SizedBox(width: 8),
                  _buildHeaderActionButton(Icons.videocam_rounded, () {
                    _confirmAndStartCall(isVideo: true);
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.isMe;

    if (message.text.startsWith('[CALL_LOG]:')) {
      final parts = message.text.split(':');
      final mode = parts.length > 1 ? parts[1] : 'audio'; // 'audio' or 'video'
      final status = parts.length > 2
          ? parts[2]
          : 'ended'; // 'ended' or 'missed'

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
                      fontFamily: 'Poppins',
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
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: isMissed ? Colors.redAccent : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•  ${message.time}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const SizedBox(width: 4),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                gradient: isMe
                    ? const LinearGradient(
                        colors: [Color(0xFFE4A834), Color(0xFFD4A437)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isMe ? AppColors.primary : Colors.black).withValues(
                      alpha: 0.08,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message.time,
                    style: TextStyle(
                      color: isMe
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.grey[400],
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildPremiumInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.textLight,
              size: 26,
            ),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.transparent),
              ),
              child: TextField(
                controller: _messageController,
                onSubmitted: (_) => _sendMessage(),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                style: const TextStyle(fontSize: 15, fontFamily: 'Poppins'),
                decoration: InputDecoration(
                  hintText: 'Message...',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: Colors.grey[400],
                    size: 22,
                  ),
                  suffix: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$_charCount/160',
                        style: TextStyle(
                          fontSize: 10,
                          color: _charCount >= 160
                              ? Colors.redAccent
                              : Colors.grey,
                        ),
                      ),
                      Text(
                        'Bal: $_remainingCharacters',
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 46,
              height: 46,
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE4A834), Color(0xFFC79527)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
