import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/iyo_theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'buttons.dart';
import 'primitives.dart';

class _StateLayout extends StatelessWidget {
  const _StateLayout({
    required this.title,
    this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.danger = false,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(IyoSpacing.xxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: danger ? IyoPalette.dangerSoft : IyoPalette.surface,
              shape: BoxShape.circle,
            ),
            child: IyoIcon(icon, size: 26, color: danger ? IyoPalette.danger : IyoPalette.ink),
          ),
          const SizedBox(height: IyoSpacing.md),
          IyoText(title, variant: IyoTextVariant.cardTitle, align: TextAlign.center, header: true),
          if (message != null) ...[
            const SizedBox(height: IyoSpacing.md),
            IyoText(message!, color: IyoPalette.textSecondary, align: TextAlign.center),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: IyoSpacing.md),
            IyoButton(
              label: actionLabel!,
              variant: IyoButtonVariant.secondary,
              size: IyoButtonSize.sm,
              fullWidth: false,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shown when a list or screen has no data yet.
class IyoEmptyState extends StatelessWidget {
  const IyoEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = LucideIcons.inbox,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => _StateLayout(
    title: title,
    message: message,
    icon: icon,
    actionLabel: actionLabel,
    onAction: onAction,
  );
}

/// Shown when loading failed; offers a retry.
class IyoErrorState extends StatelessWidget {
  const IyoErrorState({
    super.key,
    required this.title,
    this.message,
    this.icon = LucideIcons.circleAlert,
    this.retryLabel,
    this.onRetry,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => _StateLayout(
    title: title,
    message: message,
    icon: icon,
    actionLabel: retryLabel,
    onAction: onRetry,
    danger: true,
  );
}

/// Pulsing placeholder block. Compose several to sketch the loading layout.
class IyoSkeleton extends StatefulWidget {
  const IyoSkeleton({super.key, this.width, this.height = 16, this.radius = IyoRadii.sm});

  /// Null = fill the available width.
  final double? width;
  final double height;
  final double radius;

  @override
  State<IyoSkeleton> createState() => _IyoSkeletonState();
}

class _IyoSkeletonState extends State<IyoSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
    lowerBound: 0.5,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: _pulse,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: IyoPalette.surface,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}

/// Skeleton shaped like a list row.
class IyoSkeletonRow extends StatelessWidget {
  const IyoSkeletonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          IyoSkeleton(width: IyoSizes.iconWell, height: IyoSizes.iconWell, radius: IyoRadii.md),
          SizedBox(width: IyoSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(widthFactor: 0.6, child: IyoSkeleton(height: 13)),
                SizedBox(height: 6),
                FractionallySizedBox(widthFactor: 0.4, child: IyoSkeleton(height: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark strip shown at the top of a screen while the device is offline.
class IyoOfflineBanner extends StatelessWidget {
  const IyoOfflineBanner({super.key, required this.message, this.retryLabel, this.onRetry});

  final String message;
  final String? retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: IyoPalette.ink,
          borderRadius: BorderRadius.circular(IyoRadii.md),
        ),
        child: Row(
          children: [
            const IyoIcon(LucideIcons.wifiOff, size: IyoSizes.iconSmall, color: IyoPalette.white),
            const SizedBox(width: IyoSpacing.sm),
            Expanded(
              child: IyoText(message, variant: IyoTextVariant.caption, color: IyoPalette.white),
            ),
            if (retryLabel != null && onRetry != null)
              IyoPressable(
                onPressed: onRetry,
                semanticLabel: retryLabel,
                child: IyoText(
                  retryLabel!,
                  variant: IyoTextVariant.captionMedium,
                  color: context.iyo.accent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
