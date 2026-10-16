import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../widgets/driver_widgets.dart';

class VerifyArgs {
  const VerifyArgs({required this.phone, this.signUp});

  final String phone;
  final SignUpDetails? signUp;
}

String authErrorText(BuildContext context, String code) {
  final t = context.t;
  return switch (code) {
    'otp_invalid' => t.otpInvalid,
    'wrong_role' => t.wrongApp,
    'offline' => CommonLocalizations.of(context).errorOffline,
    _ => t.errorGeneric,
  };
}

class _Link extends StatelessWidget {
  const _Link({required this.lead, required this.link, required this.onPressed});

  final String lead;
  final String link;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IyoPressable(
    onPressed: onPressed,
    semanticLabel: '$lead $link',
    minHitSize: 24,
    child: IyoText('$lead $link', variant: IyoTextVariant.input, align: TextAlign.center),
  );
}

/// D1 — Welcome (rider welcome layout 2005:49905 with driver copy).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flow('01')),
      footer: [
        IyoButton(label: t.getStarted, onPressed: () => context.push('/sign-up')),
        _Link(lead: t.alreadyDriver, link: t.logIn, onPressed: () => context.push('/login')),
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
                    // TODO(design): driver illustration export (reuses the rider artwork for now).
                    Image.asset('assets/images/welcome_city.png', fit: BoxFit.cover, height: 239),
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
              style: const TextStyle(fontSize: 26, height: 1.5),
            ),
            const SizedBox(height: 12),
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

/// D2 — Log in (rider log-in layout with driver copy).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  ParsedPhone? _phone;
  String? _error;
  bool _sending = false;

  Future<void> _submit() async {
    final e164 = (_phone?.isValid ?? false ? _phone!.e164 : null);
    if (e164 == null) {
      setState(() => _error = CommonLocalizations.of(context).validationPhoneInvalid);
      return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(backendProvider).sendOtp(e164);
      if (mounted) await context.push('/verify', extra: VerifyArgs(phone: e164));
    } on BackendException catch (e) {
      if (mounted) setState(() => _error = authErrorText(context, e.code));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flow('02')),
      heading: IyoPageHeading(title: t.loginTitle, subtitle: t.loginSubtitle, onBack: context.pop),
      footer: [
        _Link(
          lead: t.newDriver,
          link: t.createAccount,
          onPressed: () => context.replace('/sign-up'),
        ),
        IyoButton(label: t.sendCode, loading: _sending, onPressed: _submit),
      ],
      children: [
        IyoPhoneField(
          label: t.fieldMobile,
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

/// D3 — Create driver account (rider sign-up layout with driver copy).
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  bool _agreed = true;
  bool _sending = false;
  String _name = '';
  ParsedPhone? _phone;
  String? _nameError;
  String? _phoneError;
  String? _formError;

  Future<void> _submit() async {
    final common = CommonLocalizations.of(context);
    final e164 = (_phone?.isValid ?? false ? _phone!.e164 : null);
    setState(() {
      _nameError = validateRequired(_name)?.message(common);
      _phoneError = e164 == null ? common.validationPhoneInvalid : null;
      _formError = null;
    });
    if (_nameError != null || e164 == null) return;
    final details = SignUpDetails(
      fullName: _name.trim(),
      role: AppRole.driver,
      language:
          Localizations.localeOf(context).languageCode == 'en' ? AppLanguage.en : AppLanguage.fr,
    );
    final backend = ref.read(backendProvider);
    if (backend is SupabaseBackend) backend.prepareSignUp(details);
    setState(() => _sending = true);
    try {
      await backend.sendOtp(e164);
      if (mounted) await context.push('/verify', extra: VerifyArgs(phone: e164, signUp: details));
    } on BackendException catch (e) {
      if (mounted) setState(() => _formError = authErrorText(context, e.code));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    const gap = SizedBox(height: 14);
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flow('03')),
      heading: IyoPageHeading(title: t.signUpTitle, subtitle: t.signUpSubtitle),
      footer: [
        if (_formError != null) Footnote(_formError!, color: IyoPalette.danger),
        _Link(lead: t.alreadyDriver, link: t.logIn, onPressed: () => context.push('/login')),
        IyoButton(
          label: t.createAndVerify,
          disabled: !_agreed,
          loading: _sending,
          onPressed: _submit,
        ),
      ],
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(alignment: Alignment.centerLeft, child: IyoBadge(t.badge)),
            gap,
            IyoTextField(
              label: t.fieldFullName,
              placeholder: 'Jean-Paul Mbarga',
              error: _nameError,
              onChanged: (v) => _name = v,
              autofillHints: const [AutofillHints.name],
            ),
            gap,
            IyoPhoneField(label: t.fieldMobile, error: _phoneError, onChanged: (v) => _phone = v),
            const SizedBox(height: 10),
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

/// D4 — Verify the phone (rider verify layout 2005:50088).
class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key, required this.args});

  final VerifyArgs args;

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  String _code = '';
  int _secondsLeft = 30;
  Timer? _timer;
  bool _verifying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
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

  Future<void> _verify([String? code]) async {
    final value = code ?? _code;
    if (value.length != 6 || _verifying) return;
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      await ref
          .read(backendProvider)
          .verifyOtp(widget.args.phone, value, signUp: widget.args.signUp);
      if (mounted) context.go('/home');
    } on BackendException catch (e) {
      if (mounted) setState(() => _error = authErrorText(context, e.code));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final demo = ref.watch(backendProvider).isDemo;
    final resend = _secondsLeft > 0 ? t.resendIn(formatDuration(_secondsLeft)) : t.resendNow;
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flow('04')),
      heading: IyoPageHeading(
        title: t.verifyTitle,
        subtitle: t.verifySubtitle(formatPhone(widget.args.phone)),
      ),
      footer: [
        IyoButton(
          label: t.verifyContinue,
          disabled: _code.length != 6,
          loading: _verifying,
          onPressed: _verify,
        ),
      ],
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IyoOtpInput(
              value: _code,
              onChanged:
                  (v) => setState(() {
                    _code = v;
                    _error = null;
                  }),
              onCompleted: _verify,
              error: _error,
              helper: demo ? t.demoCodeHint(demoOtpCode) : null,
              autofocus: true,
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: IyoPressable(
                onPressed:
                    _secondsLeft == 0
                        ? () {
                          setState(() => _secondsLeft = 30);
                          _startTimer();
                          ref.read(backendProvider).sendOtp(widget.args.phone).ignore();
                        }
                        : null,
                minHitSize: 0,
                semanticLabel: resend,
                child: IyoText(resend, color: IyoPalette.charcoal),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: IyoPressable(
                onPressed: context.pop,
                minHitSize: 0,
                semanticLabel: t.wrongNumber,
                child: IyoText(t.wrongNumber, color: IyoPalette.charcoal),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
