import 'package:flutter/material.dart';

typedef OverlayRemover = void Function();

// Shows an overlay portal anchored to an anchorKey. Returns a remover function.
OverlayRemover showOverlayPortal({
  required BuildContext context,
  required GlobalKey anchorKey,
  required Widget child,
  required ScrollController scrollController,
  VoidCallback? onClosed,
  double modalWidth = 260.0,
}) {
  final overlay = Overlay.of(context);
  final modalKey = GlobalKey<_AnimatedModalState>();
  late OverlayEntry entry;

  // scroll listener closes modal immediately
  void _scrollListener() {
    modalKey.currentState?.close();
  }

  void _internalRemove() {
    // Trigger reverse animation; modal will call onClosed after animation completes
    modalKey.currentState?.close();
  }

  void _onModalClosed() {
    try {
      entry.remove();
    } catch (_) {}
    try {
      scrollController.removeListener(_scrollListener);
    } catch (_) {}
    if (onClosed != null) onClosed();
  }

  entry = OverlayEntry(builder: (ctx) {
    final aContext = anchorKey.currentContext;
    if (aContext == null) return const SizedBox.shrink();
    final RenderBox aBox = aContext.findRenderObject() as RenderBox;
    final topLeft = aBox.localToGlobal(Offset.zero);
    double left = topLeft.dx + aBox.size.width / 2 - modalWidth / 2;
    final screenWidth = MediaQuery.of(ctx).size.width;
    left = left.clamp(8.0, screenWidth - modalWidth - 8.0);
    final top = topLeft.dy + aBox.size.height + 8.0;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Tap outside to close
          Positioned.fill(
            child: GestureDetector(
              onTap: _internalRemove,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            width: modalWidth,
            child: AnimatedModal(
              key: modalKey,
              child: child,
              onClosed: _onModalClosed,
            ),
          ),
        ],
      ),
    );
  });

  overlay.insert(entry);
  scrollController.addListener(_scrollListener);

  // Return remover that triggers the modal to play reverse animation and then remove
  return () => modalKey.currentState?.close();
}

class AnimatedModal extends StatefulWidget {
  final Widget child;
  final VoidCallback onClosed;

  const AnimatedModal({Key? key, required this.child, required this.onClosed}) : super(key: key);

  @override
  _AnimatedModalState createState() => _AnimatedModalState();
}

class _AnimatedModalState extends State<AnimatedModal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _scale = Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  Future<void> close() async {
    if (_closing) return;
    _closing = true;
    await _controller.reverse();
    widget.onClosed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Material(
          color: Colors.white,
          elevation: 12,
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
