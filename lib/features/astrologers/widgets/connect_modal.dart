import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../wallet/bloc/wallet_bloc.dart';
import '../../wallet/bloc/wallet_event.dart';
import '../../wallet/bloc/wallet_state.dart';

class ConnectModal extends StatelessWidget {
  final double chatRate;
  final double callRate;
  final double videoRate;
  final String astrologerId;
  final String astrologerName;

  const ConnectModal({
    super.key,
    required this.chatRate,
    required this.callRate,
    required this.videoRate,
    required this.astrologerId,
    required this.astrologerName,
  });

  @override
  Widget build(BuildContext context) {
    const softCreamBg = Color(0xFFFFFBF2);
    const accentGold = Color(0xFFD4AF37);

    // Watch wallet state to read balance dynamically
    final walletState = context.watch<WalletBloc>().state;
    double balance = 0.0;
    if (walletState is WalletBalanceUpdated) {
      balance = walletState.balance;
    }

    // Calculate maximum minutes/messages
    final maxChat = chatRate > 0 ? (balance / chatRate).floor() : 0;
    final maxCall = callRate > 0 ? (balance / callRate).floor() : 0;
    final maxVideo = videoRate > 0 ? (balance / videoRate).floor() : 0;

    final chatTimeText = balance >= chatRate
        ? 'Available: $maxChat messages'
        : 'Insufficient Balance';
    final callTimeText = balance >= callRate
        ? 'Available: $maxCall mins'
        : 'Insufficient Balance';
    final videoTimeText = balance >= videoRate
        ? 'Available: $maxVideo mins'
        : 'Insufficient Balance';

    void selectOption(String value, double rate) {
      if (balance < rate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFFFF5F5),
            elevation: 6,
            margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Insufficient balance! You need at least ₹${rate.toStringAsFixed(0)} to connect.',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        return;
      }

      Navigator.pop(context, value);
    }

    return Container(
      decoration: const BoxDecoration(
        color: softCreamBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Wallet Balance Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accentGold.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: accentGold,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Wallet Balance',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accentGold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Connect with $astrologerName',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose your preferred consultation method below',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Chat Option
          _buildOption(
            context,
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Chat Consultation',
            subtitle: chatTimeText,
            rateText: '₹${chatRate.toStringAsFixed(0)}/message',
            color: const Color(0xff0EA5E9),
            bgColor: const Color(0xffF0F9FF),
            value: 'chat',
            rate: chatRate,
            isAvailable: balance >= chatRate,
            onTap: () => selectOption('chat', chatRate),
          ),
          const SizedBox(height: 12),

          // Call Option
          _buildOption(
            context,
            icon: Icons.call_outlined,
            title: 'Voice Call',
            subtitle: callTimeText,
            rateText: '₹${callRate.toStringAsFixed(0)}/minute',
            color: const Color(0xff059669),
            bgColor: const Color(0xffF0FDF4),
            value: 'call',
            rate: callRate,
            isAvailable: balance >= callRate,
            onTap: () => selectOption('call', callRate),
          ),
          const SizedBox(height: 12),

          // Video Option
          _buildOption(
            context,
            icon: Icons.videocam_outlined,
            title: 'Video Call',
            subtitle: videoTimeText,
            rateText: '₹${videoRate.toStringAsFixed(0)}/minute',
            color: const Color(0xffD97706),
            bgColor: const Color(0xffFEF3C7),
            value: 'video',
            rate: videoRate,
            isAvailable: balance >= videoRate,
            onTap: () => selectOption('video', videoRate),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String rateText,
    required Color color,
    required Color bgColor,
    required String value,
    required double rate,
    required bool isAvailable,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAvailable
                ? color.withValues(alpha: 0.12)
                : Colors.redAccent.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isAvailable ? bgColor : const Color(0xFFFFF5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isAvailable ? color : Colors.redAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? Colors.black87 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isAvailable
                          ? FontWeight.normal
                          : FontWeight.w500,
                      color: isAvailable
                          ? Colors.grey
                          : Colors.redAccent.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isAvailable ? bgColor : const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rateText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isAvailable ? color : Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
