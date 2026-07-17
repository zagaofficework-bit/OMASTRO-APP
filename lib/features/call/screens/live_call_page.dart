import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omastro/features/wallet/bloc/wallet_bloc.dart';
import 'package:omastro/features/wallet/bloc/wallet_state.dart';
import 'package:omastro/features/auth/bloc/auth_bloc.dart';
import 'package:omastro/features/auth/bloc/auth_state.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repository/firebase_call_repository.dart';
import '../utils/billing_engine.dart';
import 'package:omastro/features/call/widgets/live_avatar_glow_frame.dart';
import 'package:omastro/features/call/widgets/live_call_action_card.dart';
import 'package:omastro/features/call/widgets/live_call_back_button.dart';
import 'package:omastro/features/call/widgets/live_call_background.dart';
import 'package:omastro/features/call/widgets/live_call_disconnect_button.dart';
import 'package:omastro/features/call/widgets/live_call_footer_hint.dart';
import 'package:omastro/features/call/widgets/live_caller_header.dart';

class LiveCallPage extends StatefulWidget {
  final Map<String, dynamic> astrologer;
  final String? incomingCallId;

  const LiveCallPage({
    super.key,
    required this.astrologer,
    this.incomingCallId,
  });

  @override
  State<LiveCallPage> createState() => _LiveCallPageState();
}

class _LiveCallPageState extends State<LiveCallPage> {
  final _callRepo = FirebaseCallRepository();
  final _billingEngine = BillingEngine();
  String? _callId;
  String? _roomId;
  bool _isInitializing = true;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isExiting = false;
  double _callRate = 10.0;

  void _startTimer() {
    final authState = context.read<AuthBloc>().state;
    final isAstrologer =
        authState is AuthenticatedAsAstrologer ||
        authState is AstrologerOnboardingRequired;

    double balance = 500.0; // fallback
    final walletState = context.read<WalletBloc>().state;
    if (walletState is WalletBalanceUpdated) {
      balance = walletState.balance;
    }
    _billingEngine.add(StartBillingEvent(
      perMinuteRate: _callRate,
      initialWalletBalance: balance,
      astrologerId: widget.astrologer['firebase_uid']?.toString() ?? '',
      consultationId: _callId ?? '',
      astrologerName: widget.astrologer['name']?.toString(),
      isBillingEnabled: !isAstrologer,
      consultationType: 'Audio Call',
    ));
  }

  void _stopTimer() {
    _billingEngine.add(StopBillingEvent());
  }

  Future<bool> _showAntiGravityDialog() async {
    _stopTimer(); // Freeze timer!
    final state = _billingEngine.state;
    int elapsedSeconds = 0;
    double cost = 0.0;
    
    if (state is BillingInProgress) {
       elapsedSeconds = state.durationSeconds;
       cost = state.currentCost;
    } else if (state is BillingEndedManually) {
       elapsedSeconds = state.finalDuration;
       cost = state.finalCost;
    } else if (state is BillingLowBalanceWarning) {
       elapsedSeconds = state.durationSeconds;
       cost = state.currentCost;
    }

    final mm = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final ss = (elapsedSeconds % 60).toString().padLeft(2, '0');

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('End Call?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Duration: $mm:$ss',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Cost so far: ₹${cost.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text('Do you want to end this call?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel / Resume'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Yes, End Call'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      return true;
    } else {
      _startTimer(); // Unfreeze timer
      return false;
    }
  }

  void _safeExit() {
    _stopTimer();
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

    _callRate = (widget.astrologer['call_rate'] is num)
        ? (widget.astrologer['call_rate'] as num).toDouble()
        : double.tryParse(widget.astrologer['call_rate']?.toString() ?? '10') ??
              10.0;

    if (widget.incomingCallId != null) {
      _callId = widget.incomingCallId;
      _loadRoomId();
    } else {
      _initCall();
    }
  }

  Future<void> _loadRoomId() async {
    if (_callId == null) return;
    final roomId = await _callRepo.getRoomId(_callId!);
    if (mounted) {
      setState(() {
        _roomId = roomId;
        _isInitializing = false;
      });
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _billingEngine.close();
    super.dispose();
  }

  Future<void> _initCall() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final String astrologerName = widget.astrologer['name'] ?? 'Astrologer';
    final String astrologerId =
        widget.astrologer['id']?.toString() ?? 'unknown';
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

      final roomId = await _callRepo.getRoomId(callId);
      if (mounted) {
        setState(() {
          _callId = callId;
          _roomId = roomId;
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
            LiveCallBackButton(onTap: _safeExit),
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
                letterSpacing: 0.5,
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
              children: [buildTopBar(), buildCenter(true), buildBottom()],
            ),
          ),
        ),
      );
    }

    final user = FirebaseAuth.instance.currentUser;
    final String userID =
        '${user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}'}_flutter';
    final String userName = user?.displayName ?? 'Guest';

    final zegoCall = ZegoUIKitPrebuiltCall(
      appID: int.parse(dotenv.env['ZEGO_APP_ID']!),
      appSign: dotenv.env['ZEGO_APP_SIGN']!,
      userID: userID,
      userName: userName,
      callID: _roomId ?? _callId!,
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
        ..topMenuBar.isVisible = false
        ..user.requiredUsers = ZegoCallRequiredUserConfig(enabled: false),
      events: ZegoUIKitPrebuiltCallEvents(
        onHangUpConfirmation: (event, defaultAction) async {
          return await _showAntiGravityDialog();
        },
        onCallEnd: (event, defaultAction) async {
          if (_callId != null) {
            await _callRepo.endCall(_callId!);
          }
          _safeExit();
        },
      ),
    );

    return BlocListener<BillingEngine, BillingState>(
      bloc: _billingEngine,
      listener: (context, state) {
        if (state is BillingLowBalanceWarning) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text('Low Wallet Balance! Recharge to continue. Remaining Balance: ₹${state.walletBalance.toStringAsFixed(2)}'),
               backgroundColor: Colors.orange,
             )
           );
        } else if (state is BillingEndedDueToInsufficientBalance) {
           _safeExit();
        }
      },
      child: StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('calls')
          .doc(_callId)
          .snapshots(),
      builder: (context, snapshot) {
        bool isConnecting = true;
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null &&
              (data['status'] == 'accepted' ||
                  data['status'] == 'connected' ||
                  data['status'] == 'ended' ||
                  data['status'] == 'rejected')) {
            isConnecting = false;
          }
          if (data != null &&
              (data['status'] == 'accepted' || data['status'] == 'connected')) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startTimer();
            });
          }
          if (data != null &&
              (data['status'] == 'ended' || data['status'] == 'rejected')) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _stopTimer();
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
    ),
    );
  }
}
