import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
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

  bool get _isUserAstrologer {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthenticatedAsAstrologer ||
        authState is AstrologerOnboardingRequired;
  }

  String? _pendingMessageText;
  String? _firebaseUid;
  String? _pendingCallRoute;
  String? _otherAvatarUrl;
  Map<String, dynamic>? _pendingCallExtra;
  double _callRate = 10;
  double _videoRate = 15.0;

  // New Chat Token state variables
  String? _activeTokenId;
  int _freeAttachments = 0;
  int _extraAttachments = 0;
  bool _isUploadingImage = false;
  bool _isPurchasingExtraAttachment = false;

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
    _loadActiveToken();

    _otherAvatarUrl = widget.avatarUrl;

    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserAvatar = currentUser?.photoURL;

    String? userAv = currentUserAvatar;
    String? astroAv = widget.avatarUrl;

    if (_otherAvatarUrl == null || _otherAvatarUrl!.isEmpty) {
      final queryField = (widget.id.contains('-') && widget.id.length == 36)
          ? 'id'
          : 'firebase_uid';

      Supabase.instance.client
          .from('astrologers')
          .select('avatar_url')
          .eq(queryField, _firebaseUid ?? widget.id)
          .maybeSingle()
          .then((res) {
            if (!mounted) return;
            if (res != null && res['avatar_url'] != null) {
              setState(() {
                _otherAvatarUrl = res['avatar_url']?.toString();
              });
            }
          })
          .catchError((e) {
            debugPrint('Error fetching astrologer avatar: $e');
          });
    }

    Supabase.instance.client
        .from('profiles')
        .select('avatar_url')
        .eq('id', currentUser?.uid ?? '')
        .maybeSingle()
        .then((profileRes) {
          if (!mounted) return;
          if (profileRes != null && profileRes['avatar_url'] != null) {
            userAv = profileRes['avatar_url']?.toString();
          }
          _chatBloc.add(
            OpenChatRoomEvent(
              astrologerId: widget.id,
              astrologerName: widget.name,
              astrologerFirebaseUid: _firebaseUid,
              userAvatar: userAv,
              astrologerAvatar: astroAv ?? _otherAvatarUrl,
            ),
          );
        })
        .catchError((e) {
          _chatBloc.add(
            OpenChatRoomEvent(
              astrologerId: widget.id,
              astrologerName: widget.name,
              astrologerFirebaseUid: _firebaseUid,
              userAvatar: userAv,
              astrologerAvatar: astroAv ?? _otherAvatarUrl,
            ),
          );
        });

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

  Future<void> _loadActiveToken() async {
    final isAstrologer = _isUserAstrologer;
    if (isAstrologer) return;

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Ensure _firebaseUid is resolved via Supabase if null or empty
      if (_firebaseUid == null || _firebaseUid!.isEmpty) {
        try {
          final isUuid = widget.id.length == 36 && widget.id.contains('-');
          final col = isUuid ? 'id' : 'firebase_uid';
          final astroRes = await supabase
              .from('astrologers')
              .select('firebase_uid')
              .eq(col, widget.id)
              .maybeSingle();
          if (astroRes != null && astroRes['firebase_uid'] != null) {
            _firebaseUid = astroRes['firebase_uid']?.toString();
            debugPrint(
              '[ChatRoomPage] Resolved _firebaseUid from database: $_firebaseUid',
            );
          }
        } catch (e) {
          debugPrint(
            '[ChatRoomPage] Failed to resolve _firebaseUid from database: $e',
          );
        }
      }

      final res = await supabase
          .from('chat_tokens')
          .select()
          .eq('user_id', userId)
          .eq('astrologer_id', _firebaseUid ?? widget.id)
          .eq('status', 'ACTIVE')
          .order('created_at', ascending: true)
          .limit(1)
          .maybeSingle();

      if (res != null) {
        setState(() {
          _activeTokenId = res['id'] as String;
          _remainingCharacters = res['characters_remaining'] as int;
          _freeAttachments = res['free_attachment_remaining'] as int;
          _extraAttachments = res['extra_attachment_purchased'] as int;
        });
      } else {
        setState(() {
          _activeTokenId = null;
          _remainingCharacters = 0;
          _freeAttachments = 0;
          _extraAttachments = 0;
        });
      }
    } catch (e) {
      print('Error loading active token: $e');
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    debugPrint(
      '[ChatRoomPage] _sendMessage: text = "$text", activeTokenId = $_activeTokenId, remaining = $_remainingCharacters',
    );
    if (text.isEmpty) {
      debugPrint('[ChatRoomPage] Message text is empty, aborting.');
      return;
    }

    final isAstrologer = _isUserAstrologer;

    debugPrint('[ChatRoomPage] User isAstrologer = $isAstrologer');

    if (isAstrologer) {
      context.read<ChatBloc>().add(
        SendMessageEvent(
          astrologerId: widget.id,
          astrologerName: widget.name,
          text: text,
        ),
      );
      _messageController.clear();
      return;
    }

    if (_activeTokenId == null) {
      debugPrint(
        '[ChatRoomPage] No active token found. Showing billing dialog.',
      );
      _showBillingConfirmationDialog(text);
      return;
    }

    if (_remainingCharacters >= text.length) {
      final newCharCount = _remainingCharacters - text.length;
      debugPrint(
        '[ChatRoomPage] Sufficient characters. New remaining count = $newCharCount',
      );
      setState(() {
        _remainingCharacters = newCharCount;
      });

      try {
        final supabase = Supabase.instance.client;
        debugPrint(
          '[ChatRoomPage] Updating remaining characters in Supabase token $_activeTokenId to $newCharCount',
        );
        await supabase
            .from('chat_tokens')
            .update({
              'characters_remaining': newCharCount,
              if (newCharCount == 0) 'status': 'EXHAUSTED',
            })
            .eq('id', _activeTokenId!);
        debugPrint(
          '[ChatRoomPage] Supabase remaining characters update successful.',
        );
      } catch (e) {
        debugPrint('[ChatRoomPage] Error updating remaining characters: $e');
      }

      context.read<ChatBloc>().add(
        SendMessageEvent(
          astrologerId: widget.id,
          astrologerName: widget.name,
          text: text,
        ),
      );
      _messageController.clear();

      if (newCharCount == 0) {
        debugPrint(
          '[ChatRoomPage] Token exhausted. Clearing active token state.',
        );
        setState(() {
          _activeTokenId = null;
          _freeAttachments = 0;
          _extraAttachments = 0;
        });
      }
    } else {
      debugPrint(
        '[ChatRoomPage] Insufficient characters remaining ($_remainingCharacters) for message length (${text.length}). Showing billing dialog.',
      );
      _showBillingConfirmationDialog(text);
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
                  DeductForChat(
                    amount: 5.0,
                    astrologerId: _firebaseUid ?? widget.id,
                    astrologerName: widget.name,
                  ),
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

  Future<void> _createNewChatTokenAndSendPending() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final tokenRes = await supabase
          .from('chat_tokens')
          .insert({
            'user_id': userId,
            'astrologer_id': _firebaseUid ?? widget.id,
            'characters_remaining': 160,
            'free_attachment_remaining': 2,
            'status': 'ACTIVE',
          })
          .select()
          .single();

      setState(() {
        _activeTokenId = tokenRes['id'] as String;
        _remainingCharacters = 160;
        _freeAttachments = 2;
        _extraAttachments = 0;
      });

      if (_pendingMessageText != null) {
        final textToSend = _pendingMessageText!;
        _pendingMessageText = null;

        final newCharCount = 160 - textToSend.length;
        setState(() {
          _remainingCharacters = newCharCount;
        });

        await supabase
            .from('chat_tokens')
            .update({
              'characters_remaining': newCharCount,
              if (newCharCount == 0) 'status': 'EXHAUSTED',
            })
            .eq('id', _activeTokenId!);

        context.read<ChatBloc>().add(
          SendMessageEvent(
            astrologerId: widget.id,
            astrologerName: widget.name,
            text: textToSend,
          ),
        );
        _messageController.clear();

        if (newCharCount == 0) {
          setState(() {
            _activeTokenId = null;
            _freeAttachments = 0;
            _extraAttachments = 0;
          });
        }
      }
    } catch (e) {
      debugPrint('Error creating token: $e');
    }
  }

  Future<void> _pickAndUploadAttachment() async {
    final authState = context.read<AuthBloc>().state;
    final isAstrologer =
        authState is AuthenticatedAsAstrologer ||
        authState is AstrologerOnboardingRequired;

    if (!isAstrologer) {
      if (_activeTokenId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please buy a chat token first.')),
        );
        return;
      }

      if (_freeAttachments == 0 && _extraAttachments == 0) {
        _showBuyAttachmentDialog();
        return;
      }
    }

    final picker = image_picker.ImagePicker();
    final pickedFile = await picker.pickImage(
      source: image_picker.ImageSource.gallery,
    );
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final length = await file.length();

    if (length > 5 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image exceeds 5 MB limit.')),
      );
      return;
    }

    final fileExt = pickedFile.path.split('.').last.toLowerCase();
    if (fileExt != 'png' && fileExt != 'jpg' && fileExt != 'jpeg') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only PNG, JPG, and JPEG images are allowed.'),
        ),
      );
      return;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final fileName =
          'attachments/${_activeTokenId ?? "astro"}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final supabase = Supabase.instance.client;

      await supabase.storage.from('chat_attachments').upload(fileName, file);
      final signedUrl = await supabase.storage
          .from('chat_attachments')
          .createSignedUrl(fileName, 604800);

      if (!isAstrologer) {
        if (_freeAttachments > 0) {
          final newFree = _freeAttachments - 1;
          setState(() {
            _freeAttachments = newFree;
          });
          await supabase
              .from('chat_tokens')
              .update({'free_attachment_remaining': newFree})
              .eq('id', _activeTokenId!);
        } else if (_extraAttachments > 0) {
          final newExtra = _extraAttachments - 1;
          setState(() {
            _extraAttachments = newExtra;
          });
          await supabase
              .from('chat_tokens')
              .update({'extra_attachment_purchased': newExtra})
              .eq('id', _activeTokenId!);
        }
      }

      context.read<ChatBloc>().add(
        SendMessageEvent(
          astrologerId: widget.id,
          astrologerName: widget.name,
          text: '',
          imageUrl: signedUrl,
        ),
      );

      setState(() {
        _isUploadingImage = false;
      });
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
    }
  }

  void _showBuyAttachmentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Attachments Ended'),
          content: const Text(
            'You have used your 2 free attachments. Buy 1 extra attachment for ₹5?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _isPurchasingExtraAttachment = true;
                });
                context.read<WalletBloc>().add(
                  DeductForChat(
                    amount: 5.0,
                    astrologerId: _firebaseUid ?? widget.id,
                    astrologerName: widget.name,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
              ),
              child: const Text('Buy (₹5)'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _buyAttachmentSuccess() async {
    final supabase = Supabase.instance.client;
    final newExtra = _extraAttachments + 1;
    setState(() {
      _extraAttachments = newExtra;
    });
    try {
      await supabase
          .from('chat_tokens')
          .update({'extra_attachment_purchased': newExtra})
          .eq('id', _activeTokenId!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Extra attachment purchased successfully! Tap "+" to attach.',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error updating extra attachments: $e');
    }
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

  void _confirmAndStartCall({required bool isVideo}) async {
    final rate = isVideo ? _videoRate : _callRate;
    final route = isVideo ? '/video-call' : '/live-call';
    final extra = {
      'id': widget.id,
      'name': widget.name,
      'firebase_uid': _firebaseUid,
      'image': widget.avatarUrl ?? '',
    };

    final isAstrologer = _isUserAstrologer;

    if (isAstrologer) {
      // Astrologers can initiate calls without wallet checks
      context.push(route, extra: extra);
      return;
    }

    // Check if astrologer is online before allowing user to initiate call
    if (_firebaseUid != null && _firebaseUid!.isNotEmpty) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('presence')
            .doc(_firebaseUid)
            .get();
        final isOnline = snap.data()?['is_online'] == true;
        if (!isOnline) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${widget.name} is currently offline.')),
            );
          }
          return;
        }
      } catch (_) {}
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
                context.push(route, extra: extra);
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
          if (_isPurchasingExtraAttachment) {
            _isPurchasingExtraAttachment = false;
            _buyAttachmentSuccess();
          } else if (_pendingMessageText != null &&
              _pendingMessageText!.isNotEmpty) {
            _createNewChatTokenAndSendPending();
          } else if (_pendingCallRoute != null && _pendingCallExtra != null) {
            final route = _pendingCallRoute!;
            final extra = _pendingCallExtra!;
            _pendingCallRoute = null;
            _pendingCallExtra = null;
            context.push(route, extra: extra);
          }
        } else if (state is WalletInsufficientBalance) {
          _pendingMessageText = null;
          _isPurchasingExtraAttachment = false;
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
                          final activeRoomId = state.activeRoomId;
                          if (activeRoomId != null &&
                              state.messages.containsKey(activeRoomId)) {
                            messages = state.messages[activeRoomId]!;
                          } else {
                            messages = state.messages[widget.id] ??
                                (_firebaseUid != null
                                    ? state.messages[_firebaseUid!]
                                    : null) ??
                                [];
                          }
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
                                const SizedBox(height: 16),
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
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 300),
                              child: SlideAnimation(
                                verticalOffset: 20.0,
                                child: ScaleAnimation(
                                  scale: 0.95,
                                  child: FadeInAnimation(
                                    child: _buildMessageBubble(messages[index]),
                                  ),
                                ),
                              ),
                            );
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
    return BlocBuilder<AstrologersBloc, AstrologersState>(
      builder: (context, astroState) {
        String? avatarUrl;
        bool isOnline = false;

        // 1. Try finding astrologer's details from AstrologersBloc state
        if (astroState is AstrologersFollowingState) {
          try {
            final astro = astroState.astrologers.firstWhere(
              (a) =>
                  a['id']?.toString() == widget.id.toString() ||
                  a['firebase_uid']?.toString() == widget.id.toString() ||
                  (_firebaseUid != null &&
                      a['firebase_uid']?.toString() == _firebaseUid),
            );
            if (astro['avatar_url'] != null &&
                astro['avatar_url'].toString().isNotEmpty) {
              avatarUrl = astro['avatar_url']?.toString();
            }
            if (astro['is_online'] != null) {
              isOnline = astro['is_online'] == true ||
                  astro['is_online'].toString() == 'true';
            }
          } catch (_) {}
        }

        // 2. Cascade fallback -> _otherAvatarUrl -> widget.avatarUrl
        final displayAvatar = (avatarUrl != null && avatarUrl.isNotEmpty)
            ? avatarUrl
            : ((_otherAvatarUrl != null && _otherAvatarUrl!.isNotEmpty)
                ? _otherAvatarUrl
                : widget.avatarUrl);

        final hasValidAvatar =
            displayAvatar != null && displayAvatar.isNotEmpty;

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
                      backgroundImage: hasValidAvatar
                          ? NetworkImage(displayAvatar)
                          : null,
                      child: !hasValidAvatar
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
                              decoration: BoxDecoration(
                                color: isOnline
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isOnline ? 'Online · ₹5/msg' : 'Offline · ₹5/msg',
                              style: AppTextStyles.caption.copyWith(
                                color: isOnline
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey[600],
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

    if (message.imageUrl != null && message.imageUrl!.isNotEmpty) {
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () => _openFullScreenImage(context, message.imageUrl!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      message.imageUrl!,
                      fit: BoxFit.cover,
                      width: 220,
                      height: 220,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 220,
                          height: 220,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            if (isMe) const SizedBox(width: 4),
          ],
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
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sleek capsule counter bar placed right above the chat input
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.spellcheck_rounded,
                  size: 14,
                  color: Color(0xFFD4AF37),
                ),
                const SizedBox(width: 4),
                Text(
                  'Remaining: $_remainingCharacters chars',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Container(width: 1, height: 10, color: Colors.grey.shade300),
                const SizedBox(width: 10),
                const Icon(
                  Icons.photo_library_rounded,
                  size: 14,
                  color: Color(0xFFD4AF37),
                ),
                const SizedBox(width: 4),
                Text(
                  'Photos: $_freeAttachments Free + $_extraAttachments Paid',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isUploadingImage)
                const SizedBox(
                  width: 42,
                  height: 42,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.only(bottom: 2, right: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.plus,
                      color: AppColors.textLight,
                      size: 24,
                    ),
                    onPressed: _pickAndUploadAttachment,
                    constraints: const BoxConstraints(
                      minWidth: 42,
                      minHeight: 42,
                    ),
                  ),
                ),
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
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: InputBorder.none,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          '$_charCount/160',
                          style: TextStyle(
                            fontSize: 11,
                            color: _charCount >= 160
                                ? Colors.redAccent
                                : Colors.grey,
                          ),
                        ),
                      ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.paperPlane,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void _openFullScreenImage(BuildContext context, String imageUrl) {
  Navigator.push(
    context,
    PageRouteBuilder(
      opaque: true,
      pageBuilder: (context, _, _) =>
          FullScreenImageViewer(imageUrl: imageUrl),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}

Future<void> _downloadImageDirect(BuildContext context, String url) async {
  try {
    if (Platform.isAndroid) {
      // Request storage permission first
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      // On Android 13+ (SDK 33+), Permission.storage always returns denied.
      // We must request Permission.photos as well.
      if (!status.isGranted) {
        var photosStatus = await Permission.photos.status;
        if (!photosStatus.isGranted) {
          photosStatus = await Permission.photos.request();
        }

        // If still denied, request manageExternalStorage permission
        if (!photosStatus.isGranted) {
          var manageStatus = await Permission.manageExternalStorage.status;
          if (!manageStatus.isGranted) {
            await Permission.manageExternalStorage.request();
          }
        }
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading attachment...'),
        duration: Duration(seconds: 1),
      ),
    );

    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode != 200) {
      throw 'HTTP ${response.statusCode}';
    }

    final bytes = await response.fold<List<int>>(
      [],
      (list, element) => list..addAll(element),
    );

    String savePath = '';
    if (Platform.isAndroid) {
      final dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final name = 'OmAstro_${DateTime.now().millisecondsSinceEpoch}.jpg';
      savePath = '${dir.path}/$name';
    } else {
      // iOS fallback: open in browser
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    final file = File(savePath);
    await file.writeAsBytes(bytes);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saved directly to Downloads: ${savePath.split('/').last}',
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  } catch (e) {
    debugPrint('[DirectDownload] Error: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Direct download failed. Opening in browser...'),
        ),
      );
      try {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Zoomable Image
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
              ),
            ),
          ),

          // Action Buttons top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close Button
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  // Download Button
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.download, color: Colors.white),
                      onPressed: () => _downloadImageDirect(context, imageUrl),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
