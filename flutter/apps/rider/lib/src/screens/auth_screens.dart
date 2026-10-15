import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../sample/sample_data.dart';
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

/// Log in with a phone number (R3; frame not attached, built from the sign-up layout).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _phone = '';
  String? _error;

  void _submit() {
    final e164 = toE164(_phone);
    if (e164 == null) {
      setState(() => _error = CommonLocalizations.of(context).validationPhoneInvalid);
      return;
    }
    context.push('/verify', extra: e164);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowAccount('04')),
      heading: IyoPageHeading(title: t.loginTitle, subtitle: t.loginSubtitle, onBack: context.pop),
      footer: [
        InlineLink(
          lead: t.noAccount,
          link: t.createAccount,
          onPressed: () => context.replace('/sign-up'),
        ),
        IyoButton(label: t.loginSendCode, onPressed: _submit),
      ],
      children: [
        IyoTextField(
          label: t.fieldMobile,
          prefix: '+237',
          placeholder: '6 71 23 45 67',
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          error: _error,
          onChanged:
              (v) => setState(() {
                _phone = v;
                _error = null;
              }),
        ),
      ],
    );
  }
}

/// ACCOUNT · 05 — Sign up (Figma 2005:50045).
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _agreed = true;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    // Field groups are 14 apart in the frame.
    Widget gap(double h) => SizedBox(height: h == 16 ? 14 : h);
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowAccount('05')),
      heading: IyoPageHeading(title: t.signUpTitle, subtitle: t.signUpSubtitle),
      footer: [
        InlineLink(
          lead: t.alreadyRegistered,
          link: t.logIn,
          onPressed: () => context.push('/login'),
        ),
        IyoButton(
          label: t.createAndVerify,
          disabled: !_agreed,
          onPressed: () => context.push('/verify', extra: '+237${Sample.riderPhone}'),
        ),
      ],
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(alignment: Alignment.centerLeft, child: IyoBadge(t.signUpBadge)),
            gap(16),
            IyoTextField(
              label: t.fieldFullName,
              initialValue: Sample.riderFullName,
              autofillHints: const [AutofillHints.name],
            ),
            gap(16),
            IyoTextField(
              label: t.fieldEmail,
              initialValue: Sample.riderEmail,
              helper: t.fieldEmailHelper,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
            ),
            gap(16),
            IyoTextField(
              label: t.fieldMobile,
              initialValue: Sample.riderPhoneDisplay,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
            ),
            gap(16),
            // Owner decision (15/10/2026): keep the field visually as in Figma; sign-in stays
            // phone OTP. Nothing reads this value. Revisit before Phase 4 wires real sign-up.
            IyoTextField(
              label: t.fieldPassword,
              initialValue: 'motdepasse!2026',
              obscureText: true,
              revealLabel: t.showPassword,
              helper: t.passwordRule,
              autofillHints: const [AutofillHints.newPassword],
            ),
            gap(10),
            IyoCheckbox(
              value: _agreed,
              onChanged: (v) => setState(() => _agreed = v),
              label: t.agreeTerms,
            ),
          ],
        ),
      ],
    );
  }
}

/// ACCOUNT · 06 — Verify the phone with the 6-digit SMS code (Figma 2005:50088).
class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key, this.phone});

  /// E.164 number the code was sent to.
  final String? phone;

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  String _code = '482619';
  int _secondsLeft = 24;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final phone = formatPhone(widget.phone ?? Sample.riderPhone);
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowAccount('06')),
      heading: IyoPageHeading(title: t.verifyTitle, subtitle: t.verifySubtitle(phone)),
      footer: [
        IyoButton(
          label: t.verifyContinue,
          disabled: _code.length != 6,
          onPressed: () => context.go('/home'),
        ),
      ],
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IyoOtpInput(value: _code, onChanged: (v) => setState(() => _code = v), autofocus: true),
            const SizedBox(height: 14),
            IyoPressable(
              onPressed: _secondsLeft == 0 ? () => setState(() => _secondsLeft = 30) : null,
              minHitSize: 0,
              semanticLabel:
                  _secondsLeft > 0 ? t.resendIn(formatDuration(_secondsLeft)) : t.resendNow,
              child: IyoText(
                _secondsLeft > 0 ? t.resendIn(formatDuration(_secondsLeft)) : t.resendNow,
                color: IyoPalette.charcoal,
              ),
            ),
            IyoPressable(
              onPressed: context.pop,
              minHitSize: 0,
              semanticLabel: '${t.wrongNumber} ${t.changeIt}',
              child: IyoText('${t.wrongNumber} ${t.changeIt}', color: IyoPalette.charcoal),
            ),
          ],
        ),
        IyoCard(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: IyoIcon(LucideIcons.shieldCheck, size: 24),
            ),
            IyoText(t.saferStartTitle, variant: IyoTextVariant.listTitle),
            IyoText(t.saferStartBody, color: IyoPalette.textSecondary),
          ],
        ),
      ],
    );
  }
}
