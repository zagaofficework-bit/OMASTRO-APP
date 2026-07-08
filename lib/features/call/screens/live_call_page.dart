import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  // This is the core magic: we require the specific clicked astrologer's dataset map
  final Map<String, dynamic> astrologer;

  const LiveCallPage({super.key, required this.astrologer});

  @override
  State<LiveCallPage> createState() => _LiveCallPageState();
}

class _LiveCallPageState extends State<LiveCallPage> {
  bool _isMuted = false;
  bool _isSpeakerOn = true;

  @override
  Widget build(BuildContext context) {
    // Extracting fields completely dynamically based on which list item was pressed
    final String astrologerName = widget.astrologer['name'] ?? 'Astrologer';
    final String imageUrl = widget.astrologer['image'] ?? '';

    return Scaffold(
      body: LiveCallBackground(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- 1. TOP STATUS BAR ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LiveCallBackButton(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                    ),
                    const LiveCallTimerBadge(duration: '00:21'),
                    // Transparent structural spacer matching back button layout proportions
                    const SizedBox(width: 68),
                  ],
                ),
              ),

              // --- 2. CENTER PROFILE IDENTITY DOCK ---
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LiveAvatarGlowFrame(imageUrl: imageUrl),
                  const SizedBox(height: 16),
                  const LiveStatusPill(),
                  const SizedBox(height: 12),
                  LiveCallerHeader(name: astrologerName),
                ],
              ),

              // --- 3. BOTTOM CONTROL SYSTEM ---
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LiveCallActionCard(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        isActive: _isMuted,
                        onTap: () {
                          setState(() {
                            _isMuted = !_isMuted;
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      LiveCallActionCard(
                        icon: _isSpeakerOn
                            ? Icons.volume_up
                            : Icons.volume_down,
                        isActive: !_isSpeakerOn,
                        onTap: () {
                          setState(() {
                            _isSpeakerOn = !_isSpeakerOn;
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      LiveCallDisconnectButton(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const LiveCallFooterHint(),
                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
