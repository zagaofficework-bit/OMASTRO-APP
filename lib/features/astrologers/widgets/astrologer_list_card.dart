import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';
import 'connect_modal.dart';
import '../../../../core/services/notify_service.dart';

import '../../../core/theme/app_colors.dart';

class AstrologerListCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final List<String> specialties;
  final int experienceYears;
  final List<String> languages;
  final double rating;
  final int pricePerMin;
  final bool isOnline;
  final double chatRate;
  final double callRate;
  final double videoRate;
  final String astrologerId;
  final VoidCallback onChatTap;
  final VoidCallback onCallTap;
  final VoidCallback onVideoTap;

  const AstrologerListCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.specialties,
    required this.experienceYears,
    required this.languages,
    required this.rating,
    required this.pricePerMin,
    required this.isOnline,
    required this.chatRate,
    required this.callRate,
    required this.videoRate,
    required this.astrologerId,
    required this.onChatTap,
    required this.onCallTap,
    required this.onVideoTap,
  });

  void _handleConnect(BuildContext context) async {
    if (!isOnline) {
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Astrologer Offline'),
          content: Text(
            '$name is currently offline. Would you like to be notified when they come online?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogCtx);
                final success = await NotifyService.requestNotification(
                  astrologerId: astrologerId,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: success
                          ? const Color(0xFFFFFBF2)
                          : const Color(0xFFFFF5F5),
                      elevation: 6,
                      margin: const EdgeInsets.only(
                        bottom: 24,
                        left: 16,
                        right: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: success
                              ? const Color(0xFFD4AF37)
                              : Colors.redAccent,
                          width: 1.5,
                        ),
                      ),
                      content: Row(
                        children: [
                          Icon(
                            success
                                ? Icons.check_circle_rounded
                                : Icons.error_rounded,
                            color: success
                                ? const Color(0xFFD4AF37)
                                : Colors.redAccent,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              success
                                  ? 'We will notify you when $name comes online!'
                                  : 'Failed to register notification request.',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
              ),
              child: const Text('Notify Me'),
            ),
          ],
        ),
      );
      return;
    }

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConnectModal(
        chatRate: chatRate,
        callRate: callRate,
        videoRate: videoRate,
        astrologerId: astrologerId,
        astrologerName: name,
      ),
    );

    if (result != null && context.mounted) {
      if (result == 'chat') {
        onChatTap();
      } else if (result == 'call') {
        onCallTap();
      } else if (result == 'video') {
        onVideoTap();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);
    final detailsSubtitle =
        '${specialties.join(" · ")} · $experienceYears+ yrs';
    final languageString = languages.join(', ');

    if (responsive.width < 360) {
      return _CompactAstrologerListCard(
        name: name,
        imageUrl: imageUrl,
        detailsSubtitle: detailsSubtitle,
        languageString: languageString,
        rating: rating,
        pricePerMin: pricePerMin,
        isOnline: isOnline,
        astrologerId: astrologerId,
        onConnectTap: () => _handleConnect(context),
      );
    }

    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: EdgeInsets.all(responsive.scale(16, min: 12, max: 20)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(
              imageUrl: imageUrl,
              isOnline: isOnline,
              astrologerId: astrologerId,
            ),
            SizedBox(width: responsive.scale(16, min: 12, max: 20)),
            Expanded(
              child: _AstrologerDetails(
                name: name,
                detailsSubtitle: detailsSubtitle,
                languageString: languageString,
                rating: rating,
                pricePerMin: pricePerMin,
                onConnectTap: () => _handleConnect(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x06000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    );
  }
}

class _CompactAstrologerListCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String detailsSubtitle;
  final String languageString;
  final double rating;
  final int pricePerMin;
  final bool isOnline;
  final String astrologerId;
  final VoidCallback onConnectTap;

  const _CompactAstrologerListCard({
    required this.name,
    required this.imageUrl,
    required this.detailsSubtitle,
    required this.languageString,
    required this.rating,
    required this.pricePerMin,
    required this.isOnline,
    required this.astrologerId,
    required this.onConnectTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      padding: EdgeInsets.all(responsive.scale(14, min: 12, max: 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(
                imageUrl: imageUrl,
                isOnline: isOnline,
                compact: true,
                astrologerId: astrologerId,
              ),
              SizedBox(width: responsive.scale(12, min: 10, max: 14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'PlayfairDisplay',
                        fontSize: responsive.font(19, min: 17, max: 21),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      detailsSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: responsive.font(12, min: 11, max: 13),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.scale(10, min: 8, max: 12)),
          Text(
            languageString,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: responsive.font(12, min: 11, max: 13),
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: responsive.scale(12, min: 10, max: 14)),
          Row(
            children: [
              _RatingBadge(rating: rating),
              const Spacer(),
              _PriceText(pricePerMin: pricePerMin),
              SizedBox(width: responsive.scale(8, min: 6, max: 10)),
              _ConnectButton(onTap: onConnectTap),
            ],
          ),
        ],
      ),
    );
  }
}

class _AstrologerDetails extends StatelessWidget {
  final String name;
  final String detailsSubtitle;
  final String languageString;
  final double rating;
  final int pricePerMin;
  final VoidCallback onConnectTap;

  const _AstrologerDetails({
    required this.name,
    required this.detailsSubtitle,
    required this.languageString,
    required this.rating,
    required this.pricePerMin,
    required this.onConnectTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: responsive.font(20, min: 18, max: 24),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            _RatingBadge(rating: rating),
          ],
        ),
        SizedBox(height: responsive.scale(4, min: 4, max: 6)),
        Text(
          detailsSubtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: responsive.font(13, min: 12, max: 15),
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          languageString,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: responsive.font(13, min: 12, max: 15),
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: responsive.scale(12, min: 10, max: 16)),
        Row(
          children: [
            _PriceText(pricePerMin: pricePerMin),
            const Spacer(),
            _ConnectButton(onTap: onConnectTap),
          ],
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String imageUrl;
  final bool isOnline;
  final bool compact;
  final String astrologerId;

  const _Avatar({
    required this.imageUrl,
    required this.isOnline,
    required this.astrologerId,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);
    final radius = compact
        ? responsive.scale(30, min: 28, max: 32)
        : responsive.scale(36, min: 32, max: 44);

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(responsive.scale(3, min: 2, max: 4)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xffE4A834).withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.background,
            backgroundImage: imageUrl.startsWith('assets/')
                ? AssetImage(imageUrl) as ImageProvider
                : NetworkImage(imageUrl),
          ),
        ),
        Positioned(
          right: 4,
          bottom: 2,
          child: Container(
            width: responsive.scale(16, min: 13, max: 18),
            height: responsive.scale(16, min: 13, max: 18),
            decoration: BoxDecoration(
              color: isOnline ? const Color(0xFF00BFA5) : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 2.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.scale(10, min: 8, max: 12),
        vertical: responsive.scale(4, min: 3, max: 5),
      ),
      decoration: BoxDecoration(
        color: const Color(0xffFDF6EC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star_rounded,
            color: const Color(0xffE4A834),
            size: responsive.scale(16, min: 14, max: 18),
          ),
          SizedBox(width: responsive.scale(4, min: 3, max: 5)),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: responsive.font(12, min: 11, max: 13),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceText extends StatelessWidget {
  final int pricePerMin;

  const _PriceText({required this.pricePerMin});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);

    return Text(
      'Rs $pricePerMin/min',
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: responsive.font(16, min: 14, max: 18),
        fontWeight: FontWeight.w600,
        color: const Color(0xffC7922E),
      ),
    );
  }
}

class _ConnectButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ConnectButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);
    final width = responsive.scale(90, min: 80, max: 110);
    final height = responsive.scale(38, min: 34, max: 42);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xffD4A437), Color(0xffC7922E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xffD4A437).withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome, color: Colors.white, size: 14),
              SizedBox(width: 6),
              Text(
                'Connect',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
