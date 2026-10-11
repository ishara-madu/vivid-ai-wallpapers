import 'package:flutter/material.dart';

/// A reusable minimal tactile micro-animation wrapper that provides
/// subtle scale feedback when pressed, similar to iOS/premium fluid UIs.
class BouncingWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double lowerBound;
  final Duration duration;

  const BouncingWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.lowerBound = 0.93,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<BouncingWrapper> createState() => _BouncingWrapperState();
}

class _BouncingWrapperState extends State<BouncingWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.lowerBound,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) {
      return widget.child;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// An elastic popping animation for the like/favorite heart button
class LikeHeartButton extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onTap;
  final double size;
  final Color likedColor;
  final Color unlikedColor;
  final IconData likedIcon;
  final IconData unlikedIcon;

  const LikeHeartButton({
    super.key,
    required this.isLiked,
    required this.onTap,
    this.size = 22,
    required this.likedColor,
    required this.unlikedColor,
    required this.likedIcon,
    required this.unlikedIcon,
  });

  @override
  State<LikeHeartButton> createState() => _LikeHeartButtonState();
}

class _LikeHeartButtonState extends State<LikeHeartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.35, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_animController);
  }

  @override
  void didUpdateWidget(covariant LikeHeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isLiked && widget.isLiked) {
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isLiked) {
      _animController.forward(from: 0.0);
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return BouncingWrapper(
      lowerBound: 0.88,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: widget.isLiked ? _scaleAnimation.value : 1.0,
          child: child,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) => ScaleTransition(
            scale: anim,
            child: child,
          ),
          child: Icon(
            widget.isLiked ? widget.likedIcon : widget.unlikedIcon,
            key: ValueKey<bool>(widget.isLiked),
            size: widget.size,
            color: widget.isLiked ? widget.likedColor : widget.unlikedColor,
          ),
        ),
      ),
    );
  }
}
