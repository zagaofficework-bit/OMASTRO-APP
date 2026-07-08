import 'package:flutter/material.dart';
import 'package:omastro/core/responsive/responsive_provider.dart';

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
    required this.onChatTap,
    required this.onCallTap,
    required this.onVideoTap,
  });

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
        onChatTap: onChatTap,
        onCallTap: onCallTap,
        onVideoTap: onVideoTap,
      );
    }

    return Container(
      decoration: _cardDecoration(),
      child: Padding(
        padding: EdgeInsets.all(responsive.scale(16, min: 12, max: 20)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(imageUrl: imageUrl, isOnline: isOnline),
            SizedBox(width: responsive.scale(16, min: 12, max: 20)),
            Expanded(
              child: _AstrologerDetails(
                name: name,
                detailsSubtitle: detailsSubtitle,
                languageString: languageString,
                rating: rating,
                pricePerMin: pricePerMin,
                onChatTap: onChatTap,
                onCallTap: onCallTap,
                onVideoTap: onVideoTap,
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
  final VoidCallback onChatTap;
  final VoidCallback onCallTap;
  final VoidCallback onVideoTap;

  const _CompactAstrologerListCard({
    required this.name,
    required this.imageUrl,
    required this.detailsSubtitle,
    required this.languageString,
    required this.rating,
    required this.pricePerMin,
    required this.isOnline,
    required this.onChatTap,
    required this.onCallTap,
    required this.onVideoTap,
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
              _Avatar(imageUrl: imageUrl, isOnline: isOnline, compact: true),
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
              _ActionButtons(
                onChatTap: onChatTap,
                onCallTap: onCallTap,
                onVideoTap: onVideoTap,
              ),
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
  final VoidCallback onChatTap;
  final VoidCallback onCallTap;
  final VoidCallback onVideoTap;

  const _AstrologerDetails({
    required this.name,
    required this.detailsSubtitle,
    required this.languageString,
    required this.rating,
    required this.pricePerMin,
    required this.onChatTap,
    required this.onCallTap,
    required this.onVideoTap,
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
            _ActionButtons(
              onChatTap: onChatTap,
              onCallTap: onCallTap,
              onVideoTap: onVideoTap,
            ),
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

  const _Avatar({
    required this.imageUrl,
    required this.isOnline,
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
        if (isOnline)
          Positioned(
            right: 4,
            bottom: 2,
            child: Container(
              width: responsive.scale(16, min: 13, max: 18),
              height: responsive.scale(16, min: 13, max: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA5),
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

class _ActionButtons extends StatelessWidget {
  final VoidCallback onChatTap;
  final VoidCallback onCallTap;
  final VoidCallback onVideoTap;

  const _ActionButtons({
    required this.onChatTap,
    required this.onCallTap,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);

    return Row(
      children: [
        _ActionIconButton(
          icon: Icons.chat_bubble_outline_rounded,
          isPrimary: false,
          onTap: onChatTap,
        ),
        SizedBox(width: responsive.scale(8, min: 5, max: 10)),
        _ActionIconButton(
          icon: Icons.call_outlined,
          isPrimary: false,
          onTap: onCallTap,
        ),
        SizedBox(width: responsive.scale(8, min: 5, max: 10)),
        _ActionIconButton(
          icon: Icons.videocam_outlined,
          isPrimary: true,
          onTap: onVideoTap,
        ),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveProvider.of(context);
    final size = responsive.scale(38, min: 34, max: 42);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPrimary ? const Color(0xffD4A437) : Colors.transparent,
            border: isPrimary
                ? null
                : Border.all(color: const Color(0xffEFEAE2), width: 1.2),
          ),
          child: Icon(
            icon,
            size: responsive.scale(18, min: 16, max: 20),
            color: isPrimary ? Colors.black87 : const Color(0xff707070),
          ),
        ),
      ),
    );
  }
}
