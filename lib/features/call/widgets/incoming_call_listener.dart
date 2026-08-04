import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omastro/app/route.dart';
import 'package:omastro/features/auth/bloc/auth_bloc.dart';
import 'package:omastro/features/auth/bloc/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class IncomingCallListener extends StatefulWidget {
  final Widget child;
  const IncomingCallListener({super.key, required this.child});

  @override
  State<IncomingCallListener> createState() => _IncomingCallListenerState();
}

class _IncomingCallListenerState extends State<IncomingCallListener> {
  String? _ringingCallId;
  bool _isCallAccepted = false;

  void _handleIncomingCall(Map<String, dynamic> callData, String callId) {
    if (_ringingCallId == callId) return;
    _ringingCallId = callId;
    _isCallAccepted = false;

    FlutterRingtonePlayer().playRingtone(looping: true);

    // Use NavigatorState directly — avoids "does not include a Navigator" error
    // that occurs when using showDialog with a GoRouter context.
    rootNavigatorKey.currentState?.push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        barrierDismissible: false,
        pageBuilder: (ctx, _, _) => PopScope(
          canPop: false,
          child: _IncomingCallOverlay(
            callId: callId,
            callData: callData,
            onAccept: () {
              setState(() {
                _isCallAccepted = true;
              });
            },
            onClose: () {
              FlutterRingtonePlayer().stop();
              _ringingCallId = null;
              _isCallAccepted = false;
              rootNavigatorKey.currentState?.pop();
            },
          ),
        ),
      ),
    );
  }

  void _dismissDialog() {
    FlutterRingtonePlayer().stop();
    _ringingCallId = null;
    _isCallAccepted = false;
    if (rootNavigatorKey.currentState?.canPop() == true) {
      rootNavigatorKey.currentState?.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isLoggedIn = authState is Authenticated || authState is AuthenticatedAsAstrologer;
        if (isLoggedIn) {
          final uid = FirebaseAuth.instance.currentUser?.uid;
          if (uid == null) return widget.child;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('calls')
                .where('calleeUid', isEqualTo: uid)
                .where('status', isEqualTo: 'ringing')
                .snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              // Sort newest first client-side (avoids composite index requirement)
              docs.sort((a, b) {
                final ta = (a.data() as Map)['createdAt'] as Timestamp?;
                final tb = (b.data() as Map)['createdAt'] as Timestamp?;
                return (tb?.millisecondsSinceEpoch ?? 0)
                    .compareTo(ta?.millisecondsSinceEpoch ?? 0);
              });

              if (docs.isNotEmpty) {
                final doc = docs.first;
                final data = doc.data() as Map<String, dynamic>;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _handleIncomingCall(data, doc.id);
                });
              } else if (_ringingCallId != null) {
                // The doc disappeared from ringing status (caller hung up / user accepted)
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    if (!_isCallAccepted) {
                      _dismissDialog();
                    } else {
                      // Reset state silently as accept handles navigation and overlay pop
                      _ringingCallId = null;
                      _isCallAccepted = false;
                    }
                  }
                });
              }
              return widget.child;
            },
          );
        }
        return widget.child;
      },
    );
  }
}


class _IncomingCallOverlay extends StatelessWidget {
  final String callId;
  final Map<String, dynamic> callData;
  final VoidCallback onAccept;
  final VoidCallback onClose;

  const _IncomingCallOverlay({
    required this.callId,
    required this.callData,
    required this.onAccept,
    required this.onClose,
  });

  Future<void> _acceptCall() async {
    onAccept(); // Mark call as accepted in parent listener BEFORE updating firestore
    
    await FirebaseFirestore.instance.collection('calls').doc(callId).update({
      'status': 'accepted',
    });

    final mode = callData['mode'] ?? 'audio';
    final astrologerData = {
      'id': callData['callerUid'] ?? '',
      'name': callData['callerName'] ?? 'Astrologer',
      'image': callData['callerAvatar'] ?? '',
      'firebase_uid': callData['callerUid'] ?? '',
    };

    onClose(); // stops ringtone + pops overlay route

    // Push AFTER the pop frame settles — prevents !_debugLocked assertion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mode == 'video') {
        appRouter.push('/video-call', extra: {'astrologer': astrologerData, 'incomingCallId': callId});
      } else {
        appRouter.push('/live-call', extra: {'astrologer': astrologerData, 'incomingCallId': callId});
      }
    });
  }

  Future<void> _declineCall() async {
    await FirebaseFirestore.instance.collection('calls').doc(callId).update({
      'status': 'rejected',
    });
    onClose();
  }

  @override
  Widget build(BuildContext context) {
    final callerName = callData['callerName'] ?? 'Astrologer';
    final mode = callData['mode'] ?? 'audio';
    
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.black87,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 24),
              Text(
                callerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Incoming ${mode == 'video' ? 'Video' : 'Audio'} Call...',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    label: 'Decline',
                    onTap: _declineCall,
                  ),
                  _buildButton(
                    icon: mode == 'video' ? Icons.videocam : Icons.call,
                    color: Colors.green,
                    label: 'Accept',
                    onTap: _acceptCall,
                  ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
