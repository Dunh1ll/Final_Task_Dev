import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TransparentCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const TransparentCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  State<TransparentCard> createState() => _TransparentCardState();
}

class _TransparentCardState extends State<TransparentCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _handleEnter(PointerEvent event) {
    setState(() => _isHovered = true);
  }

  void _handleExit(PointerEvent event) {
    setState(() => _isHovered = false);
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS;

    double scale = 1.0;
    if (_isPressed) {
      scale = 0.98;
    } else if (_isHovered) {
      scale = CardEffects.hoverScale;
    }

    Widget cardContent = AnimatedContainer(
      duration: AppDurations.cardHover,
      curve: Curves.easeOut,
      transform: Matrix4.identity()..scale(scale),
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: _isHovered || _isPressed
                  ? CardEffects.hoverShadow
                  : CardEffects.defaultShadow,
            ),
            child: widget.child,
          ),
        ),
      ),
    );

    if (isMobile) {
      return GestureDetector(
        onTap: widget.onTap,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: cardContent,
      );
    }

    return MouseRegion(
      onEnter: _handleEnter,
      onExit: _handleExit,
      child: GestureDetector(
        onTap: widget.onTap,
        child: cardContent,
      ),
    );
  }
}
