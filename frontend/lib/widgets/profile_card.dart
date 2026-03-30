import 'package:flutter/material.dart';
import '../models/user_base.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';

/// ProfileCard displays a user profile in the main carousel.
/// Supports hover effects, edit/delete buttons, and all image types.
class ProfileCard extends StatefulWidget {
  final UserBase user;
  final bool isCenter;
  final VoidCallback onTap;
  final bool showEditButton;
  final bool showDeleteButton;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProfileCard({
    super.key,
    required this.user,
    required this.isCenter,
    required this.onTap,
    this.showEditButton = false,
    this.showDeleteButton = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _handleEnter(PointerEvent e) => setState(() => _isHovered = true);
  void _handleExit(PointerEvent e) => setState(() => _isHovered = false);
  void _handleTapDown(TapDownDetails d) => setState(() => _isPressed = true);
  void _handleTapUp(TapUpDetails d) => setState(() => _isPressed = false);
  void _handleTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    final isMobile = Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS;

    // Card dimensions
    const baseWidth = 480.0;
    const baseHeight = 380.0;

    // Scale based on interaction state
    double scale = 1.0;
    if (_isPressed)
      scale = 0.97;
    else if (_isHovered) scale = 1.02;

    // Shadow style changes on hover
    List<BoxShadow> shadows;
    if (_isHovered || _isPressed) {
      shadows = [
        BoxShadow(
          color: AppColors.darkGreen.withOpacity(0.8),
          blurRadius: 35,
          spreadRadius: 8,
          offset: const Offset(-15, 0),
        ),
        BoxShadow(
          color: AppColors.darkGreen.withOpacity(0.8),
          blurRadius: 35,
          spreadRadius: 8,
          offset: const Offset(15, 0),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 5,
          offset: const Offset(0, 10),
        ),
      ];
    } else if (widget.isCenter) {
      shadows = [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 5,
          offset: const Offset(0, 10),
        ),
      ];
    } else {
      shadows = CardEffects.defaultShadow;
    }

    Widget cardContent = AnimatedContainer(
      duration: AppDurations.cardHover,
      curve: Curves.easeOut,
      transform: Matrix4.identity()
        ..scale(widget.isCenter
            ? CardEffects.centerScale * scale
            : CardEffects.defaultScale * scale),
      // ✅ FIX: ClipRRect prevents card content overflowing rounded corners
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: Container(
            width: baseWidth,
            height: baseHeight,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.dirtyWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: shadows,
              border: _isHovered
                  ? Border.all(
                      color: AppColors.darkGreen.withOpacity(0.6),
                      width: 3,
                    )
                  : null,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Card body ────────────────────────────────────
                Column(
                  children: [
                    // ── Cover photo section ───────────────────────
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Cover photo
                        Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            image: DecorationImage(
                              // ✅ Uses ImageHelper for base64 support
                              image: ImageHelper.buildProvider(
                                widget.user.coverPhoto,
                                AssetPaths.defaultCover,
                                bytes: widget.user.coverPhotoBytes,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Profile picture overlapping cover
                        Positioned(
                          bottom: -45,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.dirtyWhite,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                                image: DecorationImage(
                                  // ✅ Uses ImageHelper for base64 support
                                  image: ImageHelper.buildProvider(
                                    widget.user.profilePicture,
                                    AssetPaths.defaultAvatar,
                                    bytes: widget.user.profilePictureBytes,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 52),

                    // Name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        widget.user.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGray,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Bio
                    if (widget.user.bio != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          widget.user.bio!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.lightGray,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    const Spacer(),

                    // Info chips at bottom
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.user.age != null)
                            _buildChip('${widget.user.age} years'),
                          if (widget.user.yearLevel != null) ...[
                            const SizedBox(width: 8),
                            _buildChip(widget.user.yearLevel!),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Edit button ───────────────────────────────────
                if (widget.showEditButton)
                  Positioned(
                    top: 8,
                    right: widget.showDeleteButton ? 48 : 8,
                    child: GestureDetector(
                      onTap: widget.onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),

                // ── Delete button ─────────────────────────────────
                if (widget.showDeleteButton)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: widget.onDelete,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (isMobile) return cardContent;

    return MouseRegion(
      onEnter: _handleEnter,
      onExit: _handleExit,
      child: cardContent,
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
