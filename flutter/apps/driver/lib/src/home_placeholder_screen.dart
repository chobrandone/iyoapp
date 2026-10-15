import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../l10n/gen/app_localizations.dart';
import 'locale_controller.dart';

/// Placeholder home: proves shared UI, Poppins, formatters and EN/FR strings are wired up.
class HomePlaceholderScreen extends ConsumerWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';

    return IyoScreen(
      header: IyoAppHeader(badge: t.placeholderBadge, flowLabel: t.placeholderFlowLabel),
      footer: [
        IyoButton(label: t.placeholderPrimary, onPressed: () {}),
        IyoButton(
          label: t.placeholderSecondary,
          variant: IyoButtonVariant.secondary,
          onPressed:
              () => ref.read(localeControllerProvider.notifier).set(Locale(isFrench ? 'en' : 'fr')),
        ),
        if (kDebugMode)
          IyoButton(
            label: 'Component gallery (dev)',
            variant: IyoButtonVariant.ghost,
            onPressed: () => context.push('/dev/components'),
          ),
      ],
      children: [
        IyoPageHeading(hero: true, title: t.placeholderTitle, subtitle: t.placeholderSubtitle),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IyoText(t.placeholderSampleFare(formatFcfa(18500))),
            const SizedBox(height: IyoSpacing.xs),
            IyoText(t.placeholderSampleTime(formatDateTime(DateTime.now()))),
            const SizedBox(height: IyoSpacing.xs),
            IyoText(
              t.placeholderSamplePhone(formatPhone('671234567')),
              variant: IyoTextVariant.caption,
              color: IyoPalette.textSecondary,
            ),
          ],
        ),
      ],
    );
  }
}
