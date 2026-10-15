import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../widgets/rider_widgets.dart';

/// START · 01 — Welcome (Figma 2005:49905).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowStart('01')),
      footer: [
        IyoButton(label: t.welcomeGetStarted, onPressed: () => context.push('/sign-up')),
        InlineLink(
          lead: t.welcomeHaveAccount,
          link: t.logIn,
          onPressed: () => context.push('/login'),
        ),
      ],
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(IyoRadii.xl),
              child: ColoredBox(
                color: IyoPalette.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 121,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
                        child: IyoText(
                          t.welcomeHeroTitle,
                          variant: IyoTextVariant.hero,
                          color: IyoPalette.black,
                          style: const TextStyle(fontSize: 42, height: 1.12, letterSpacing: -0.6),
                        ),
                      ),
                    ),
                    // TODO(design): replace with the 2x/3x export of the Figma illustration (and a
                    // Douala skyline version: the frame shows London landmarks).
                    Image.asset(
                      'assets/images/welcome_city.png',
                      fit: BoxFit.cover,
                      height: 239,
                      semanticLabel: t.welcomeBadge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            IyoBadge(t.welcomeBadge),
            const SizedBox(height: 13),
            IyoText(
              t.welcomeHeadline,
              variant: IyoTextVariant.title,
              style: const TextStyle(fontSize: 30, height: 46 / 30),
            ),
            const SizedBox(height: 15),
            IyoText(
              t.welcomeBody,
              variant: IyoTextVariant.input,
              color: IyoPalette.textSecondary,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ],
    );
  }
}
