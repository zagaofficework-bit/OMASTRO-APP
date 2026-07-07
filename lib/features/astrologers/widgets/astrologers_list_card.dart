import 'package:flutter/material.dart';
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
    final String detailsSubtitle =
        '${specialties.join(" · ")} · $experienceYears+ yrs';
    final String languageString = languages.join(", ");

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Profile Avatar Section ---
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xffE4A834).withValues(alpha: 0.4),
                      width: 2.0,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.background,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    right: 4,
                    bottom: 2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BFA5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surface,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // --- Info Details Section ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffFDF6EC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xffE4A834),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detailsSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    languageString,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- Lower Row (With layout fix) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '₹$pricePerMin/min',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xffC7922E),
                        ),
                      ),
                      Row(
                        children: [
                          _ActionIconButton(
                            icon: Icons.chat_bubble_outline_rounded,
                            isPrimary: false,
                            onTap: onChatTap,
                          ),
                          const SizedBox(width: 8),
                          _ActionIconButton(
                            icon: Icons.call_outlined,
                            isPrimary: false,
                            onTap: onCallTap,
                          ),
                          const SizedBox(width: 8),
                          _ActionIconButton(
                            icon: Icons.videocam_outlined,
                            isPrimary: true,
                            onTap: onVideoTap,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPrimary ? const Color(0xffD4A437) : Colors.transparent,
            border: isPrimary
                ? null
                : Border.all(color: const Color(0xffEFEAE2), width: 1.2),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isPrimary ? Colors.black87 : const Color(0xff707070),
          ),
        ),
      ),
    );
  }
}
