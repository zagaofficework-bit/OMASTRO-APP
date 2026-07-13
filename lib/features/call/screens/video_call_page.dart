import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../repository/firebase_call_repository.dart';

class VideoCallPage extends StatefulWidget {
  final Map<String, dynamic> astrologer;

  const VideoCallPage({super.key, required this.astrologer});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final _callRepo = FirebaseCallRepository();
  String? _callId;
  bool _isInitializing = true;
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isFrontCamera = true;

  @override
  void initState() {
    super.initState();
    _initCall();
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
        mode: 'video',
      );
      
      if (mounted) {
        setState(() {
          _callId = callId;
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint('[VideoCallPage] Error starting call: $e');
      if (mounted) Navigator.of(context).pop();
    }
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white12,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: isActive ? AppColors.darkBackground : Colors.white,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String astrologerName = widget.astrologer['name'] ?? 'Astrologer';
    final String imageUrl = widget.astrologer['image'] ?? 'assets/images/logo.png';

    final user = FirebaseAuth.instance.currentUser;
    final String userID = '${user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}'}_flutter';
    final String userName = user?.displayName ?? 'Guest';

    Widget buildTopBar(bool isConnecting) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  if (context.canPop()) context.pop();
                  else context.go('/home');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text('Back', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  CircleAvatar(radius: 18, backgroundImage: AssetImage(imageUrl)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        astrologerName,
                        style: const TextStyle(
                          color: Colors.white, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 14, 
                          fontFamily: 'PlayfairDisplay',
                          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isConnecting ? 'CONNECTING...' : 'LIVE',
                        style: const TextStyle(
                          color: Colors.white60, 
                          fontSize: 11,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6, 
                  height: 6, 
                  decoration: BoxDecoration(
                    color: isConnecting ? Colors.orangeAccent : Colors.greenAccent, 
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (!isConnecting)
                        const BoxShadow(color: Colors.greenAccent, blurRadius: 4)
                    ]
                  )
                ),
                const SizedBox(width: 6),
                Text(
                  isConnecting ? 'WAITING' : 'LIVE',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget buildConnectingCenter() {
      return Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 2),
          ),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    Widget buildConnectingBottom() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
            child: const Text('Connecting to astrologer...', style: TextStyle(color: Colors.white70, fontSize: 11)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                icon: _isMuted ? Icons.mic_off : Icons.mic_none_rounded,
                isActive: _isMuted,
                onTap: () => setState(() => _isMuted = !_isMuted),
              ),
              const SizedBox(width: 14),
              _buildControlButton(
                icon: _isVideoOff ? Icons.videocam_off_outlined : Icons.videocam_outlined,
                isActive: _isVideoOff,
                onTap: () => setState(() => _isVideoOff = !_isVideoOff),
              ),
              const SizedBox(width: 14),
              _buildControlButton(
                icon: Icons.flip_camera_ios_outlined,
                isActive: false,
                onTap: () => setState(() => _isFrontCamera = !_isFrontCamera),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                onTap: () async {
                  if (_callId != null) {
                    await _callRepo.endCall(_callId!);
                  }
                  if (mounted) {
                    if (context.canPop()) context.pop();
                    else context.go('/home');
                  }
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.redAccent, blurRadius: 10, offset: Offset(0, 2))],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 26),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (_isInitializing || _callId == null) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(top: 16, left: 16, right: 16, child: buildTopBar(true)),
              buildConnectingCenter(),
              Positioned(bottom: 24, left: 16, right: 16, child: buildConnectingBottom()),
            ],
          ),
        ),
      );
    }

    final zegoCall = ZegoUIKitPrebuiltCall(
      appID: int.parse(dotenv.env['ZEGO_APP_ID']!),
      appSign: dotenv.env['ZEGO_APP_SIGN']!,
      userID: userID,
      userName: userName,
      callID: _callId!,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        ..topMenuBar.isVisible = false
        ..user.requiredUsers = ZegoCallRequiredUserConfig(enabled: false),
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
               if (mounted) {
                 if (context.canPop()) context.pop();
                 else context.go('/home');
               }
             });
          }
        }
        
        return Scaffold(
          backgroundColor: isConnecting ? AppColors.darkBackground : Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                if (!isConnecting) zegoCall, // Zego renders below our Top Bar
                Positioned(top: 16, left: 16, right: 16, child: buildTopBar(isConnecting)),
                
                if (isConnecting) ...[
                  buildConnectingCenter(),
                  Positioned(bottom: 24, left: 16, right: 16, child: buildConnectingBottom()),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
