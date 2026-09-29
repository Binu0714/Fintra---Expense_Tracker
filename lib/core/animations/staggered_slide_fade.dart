import 'package:flutter/material.dart';

class StaggeredSlideFade extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final double verticalOffset;

  const StaggeredSlideFade({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 550),
    this.verticalOffset = -22.0,
  });

  @override
  State<StaggeredSlideFade> createState() => _StaggeredSlideFadeState();
}

class _StaggeredSlideFadeState extends State<StaggeredSlideFade>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.verticalOffset / 100),
      end: Offset.zero,
    ).animate(curved);

    Future.delayed(Duration(milliseconds: (widget.index * 65).clamp(0, 450)), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}