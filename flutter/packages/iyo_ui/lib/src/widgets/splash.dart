import 'package:flutter/widgets.dart';

/// The company logo on its own colour for a moment at launch, then a fade into the app.
/// Continues the Android launch screen (same logo and colour), so there is no visible jump.
/// The app builds underneath straight away; the splash only covers it.
class IyoSplash extends StatefulWidget {
  const IyoSplash({
    super.key,
    required this.logo,
    required this.background,
    required this.label,
    required this.child,
    this.hold = const Duration(milliseconds: 1400),
  });

  /// Square logo artwork (the same image as the launcher icon).
  final ImageProvider logo;
  final Color background;

  /// Read by screen readers while the splash shows (the app name).
  final String label;
  final Widget child;
  final Duration hold;

  @override
  State<IyoSplash> createState() => _IyoSplashState();
}

class _IyoSplashState extends State<IyoSplash> {
  bool _fading = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.hold, () {
      if (mounted) setState(() => _fading = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (!_done)
            AnimatedOpacity(
              opacity: _fading ? 0 : 1,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              onEnd: () => setState(() => _done = true),
              child: Semantics(
                label: widget.label,
                image: true,
                child: ColoredBox(
                  color: widget.background,
                  child: Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.62,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image(image: widget.logo, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
