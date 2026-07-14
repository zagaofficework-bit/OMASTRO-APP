import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repository/firebase_call_repository.dart';
import 'package:omastro/features/call/widgets/live_avatar_glow_frame.dart';
import 'package:omastro/features/call/widgets/live_call_action_card.dart';
import 'package:omastro/features/call/widgets/live_call_back_button.dart';
import 'package:omastro/features/call/widgets/live_call_background.dart';
import 'package:omastro/features/call/widgets/live_call_disconnect_button.dart';
import 'package:omastro/features/call/widgets/live_call_footer_hint.dart';
import 'package:omastro/features/call/widgets/live_caller_header.dart';
import 'package:omastro/features/call/widgets/live_calling_timer_badge.dart';
import 'package:omastro/features/call/widgets/live_status_pill.dart';

class LiveCallPage extends StatefulWidget {
  final Map<String, dynamic> astrologer;
  final String? incomingCallId;

  const LiveCallPage({super.key, required this.astrologer, this.incomingCallId});

  @override
  State<LiveCallPage> createState() => _LiveCallPageState();
}

class _LiveCallPageState extends State<LiveCallPage> {
  final _callRepo = FirebaseCallRepository();
  String? _callId;
  bool _isInitializing = true;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isExiting = false;

  void _safeExit() {
    if (_isExiting) return;
    _isExiting = true;
    if (mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.incomingCallId != null) {
      setState(() {
        _callId = widget.incomingCallId;
        _isInitializing = false;
      });
    } else {
      _initCall();
    }
  }

  Future<void> _initCall() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final String astrologerName = widget.astrologer['name'] ?? 'Astrologer';
    final String astrologerId = widget.astrologer['id']?.toString() ?? 'unknown';
    final String? firebaseUid = widget.astrologer['firebase_uid']?.toString();

    try {
      final callId = await _callRepo.startCall(
        callerUid: user.uid,
        callerName: user.displayName ?? 'Guest',
        calleeName: astrologerName,
        astrologerId: astrologerId,
        calleeFirebaseUid: firebaseUid,
        mode: 'audio',
      );
      
      if (mounted) {
        setState(() {
          _callId = callId;
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('[LiveCallPage] Error starting call: $e');
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String astrologerName = widget.astrologer['name'] ?? 'Astrologer';
    final String imageUrl = widget.astrologer['image'] ?? '';

    Widget buildTopBar() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            LiveCallBackButton(
              onTap: _safeExit,
            ),
            const SizedBox(width: 68), // Spacer
          ],
        ),
      );
    }

    Widget buildCenter(bool isConnecting) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiveAvatarGlowFrame(imageUrl: imageUrl),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24, width: 0.8),
            ),
            child: Text(
              isConnecting ? 'CONNECTING...' : 'LIVE',
              style: TextStyle(
                color: isConnecting ? Colors.white : Colors.greenAccent, 
                fontSize: 10, 
                fontWeight: FontWeight.bold, 
                letterSpacing: 0.5
              ),
            ),
          ),
          const SizedBox(height: 12),
          LiveCallerHeader(name: astrologerName),
        ],
      );
    }

    Widget buildBottom() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LiveCallActionCard(
                icon: _isMuted ? Icons.mic_off : Icons.mic,
                isActive: _isMuted,
                onTap: () => setState(() => _isMuted = !_isMuted),
              ),
              const SizedBox(width: 20),
              LiveCallActionCard(
                icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                isActive: !_isSpeakerOn,
                onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
              ),
              const SizedBox(width: 20),
              LiveCallDisconnectButton(
                onTap: () async {
                  if (_callId != null) {
                    await _callRepo.endCall(_callId!);
                  }
                  _safeExit();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const LiveCallFooterHint(),
          const SizedBox(height: 24),
        ],
      );
    }

    if (_isInitializing || _callId == null) {
      return Scaffold(
        body: LiveCallBackground(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildTopBar(),
                buildCenter(true),
                buildBottom(),
              ],
            ),
          ),
        ),
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    final String userID = '${user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}'}_flutter';
    final String userName = user?.displayName ?? 'Guest';

    final zegoCall = ZegoUIKitPrebuiltCall(
      appID: int.parse(dotenv.env['ZEGO_APP_ID']!),
      appSign: dotenv.env['ZEGO_APP_SIGN']!,
      userID: userID,
      userName: userName,
      callID: _callId!,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
        ..topMenuBar.isVisible = false
        ..user.requiredUsers = ZegoCallRequiredUserConfig(enabled: false),
      events: ZegoUIKitPrebuiltCallEvents(
        onCallEnd: (event, defaultAction) async {
          if (_callId != null) {
            await _callRepo.endCall(_callId!);
          }
          // DO NOT call defaultAction.call() here because it performs a Navigator.pop().
          // _safeExit() already handles the navigation logic and prevents double pops.
          _safeExit();
        },
      ),
    );

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('calls').doc(_callId).snapshots(),
      builder: (context, snapshot) {
        bool isConnecting = true;
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null && (data['status'] == 'accepted' || data['status'] == 'connected' || data['status'] == 'ended' || data['status'] == 'rejected')) {
            isConnecting = false;
          }
          if (data != null && (data['status'] == 'ended' || data['status'] == 'rejected')) {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               _safeExit();
             });
          }
        }
        
        return Scaffold(
          body: Stack(
            children: [
              if (!isConnecting) zegoCall,
              if (isConnecting)
                LiveCallBackground(
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildTopBar(),
                        buildCenter(true),
                        buildBottom(),
                      ],
                    ),
                  ),
                )
              else
                SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildTopBar(),
                      // For audio calls, let's also keep our center avatar so it doesn't look empty!
                      // Zego's audio UI is just dark anyway. We can pass IgnorePointer so we can still tap Zego buttons if needed
                      IgnorePointer(child: buildCenter(false)),
                      const Spacer(), 
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
