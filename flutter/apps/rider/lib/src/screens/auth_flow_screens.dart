import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../sample/sample_data.dart';
import '../widgets/rider_widgets.dart';

/// Arguments for the verify screen.
class VerifyArgs {
  const VerifyArgs({required this.phone, this.signUp});

  /// E.164 number the code was sent to.
  final String phone;
  final SignUpDetails? signUp;
}

/// Maps backend error codes to a message for the rider.
String authErrorText(BuildContext context, String code) {
  final t = context.t;
  final common = CommonLocalizations.of(context);
  return switch (code) {
    'otp_invalid' => t.otpInvalid,
    'wrong_role' => t.wrongApp,
    'offline' => common.errorOffline,
    _ => common.errorGeneric,
  };
}

/// Log in with a phone number (R3; frame not attached, built from the sign-up layout).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _phone = '';
  String? _error;
  bool _sending = false;

  Future<void> _submit() async {
    final e164 = toE164(_phone);
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
      header: IyoAppHeader(flowLabel: t.flowAccount('04')),
      heading: IyoPageHeading(title: t.loginTitle, subtitle: t.loginSubtitle, onBack: context.pop),
      footer: [
        InlineLink(
          lead: t.noAccount,
          link: t.createAccount,
          onPressed: () => context.replace('/sign-up'),
        ),
        IyoButton(label: t.loginSendCode, loading: _sending, onPressed: _submit),
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
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  bool _agreed = true;
  bool _sending = false;
  String _name = '';
  String _email = '';
  String _phone = '';
  String? _nameError;
  String? _phoneError;
  String? _formError;

  Future<void> _submit() async {
    final common = CommonLocalizations.of(context);
    final e164 = toE164(_phone);
    setState(() {
      _nameError = validateRequired(_name)?.message(common);
      _phoneError = e164 == null ? common.validationPhoneInvalid : null;
      _formError = null;
    });
    if (_nameError != null || e164 == null) return;
    final lang =
        Localizations.localeOf(context).languageCode == 'en' ? AppLanguage.en : AppLanguage.fr;
    final details = SignUpDetails(
      fullName: _name.trim(),
      email: _email.trim().isEmpty ? null : _email.trim(),
      role: AppRole.rider,
      language: lang,
    );
    final backend = ref.read(backendProvider);
    if (backend is SupabaseBackend) backend.prepareSignUp(details);
    setState(() => _sending = true);
    try {
      await backend.sendOtp(e164);
      if (mounted) {
        await context.push('/verify', extra: VerifyArgs(phone: e164, signUp: details));
      }
    } on BackendException catch (e) {
      if (mounted) setState(() => _formError = authErrorText(context, e.code));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    // Field groups are 14 apart in the frame.
    const gap = SizedBox(height: 14);
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowAccount('05')),
      heading: IyoPageHeading(title: t.signUpTitle, subtitle: t.signUpSubtitle),
      footer: [
        if (_formError != null)
          IyoText(_formError!, variant: IyoTextVariant.caption, color: IyoPalette.danger),
        InlineLink(
          lead: t.alreadyRegistered,
          link: t.logIn,
          onPressed: () => context.push('/login'),
        ),
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
            Align(alignment: Alignment.centerLeft, child: IyoBadge(t.signUpBadge)),
            gap,
            IyoTextField(
              label: t.fieldFullName,
              placeholder: Sample.riderFullName,
              error: _nameError,
              onChanged: (v) => _name = v,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
            ),
            gap,
            IyoTextField(
              label: t.fieldEmail,
              placeholder: Sample.riderEmail,
              helper: t.fieldEmailHelper,
              onChanged: (v) => _email = v,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
            ),
            gap,
            IyoTextField(
              label: t.fieldMobile,
              placeholder: Sample.riderPhoneDisplay,
              error: _phoneError,
              onChanged: (v) => _phone = v,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
            ),
            gap,
            // Owner decision (15/10/2026): keep the field visually as in Figma; sign-in stays
            // phone OTP. Nothing reads this value. Revisit before Phase 4 wires real sign-up.
            IyoTextField(
              label: t.fieldPassword,
              obscureText: true,
              revealLabel: t.showPassword,
              helper: t.passwordRule,
              autofillHints: const [AutofillHints.newPassword],
            ),
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

/// ACCOUNT · 06 — Verify the phone with the 6-digit SMS code (Figma 2005:50088).
/// Without [args] it renders the design preview (sample number and code).
class VerifyScreen extends ConsumerStatefulWidget {
  const VerifyScreen({super.key, this.args});

  final VerifyArgs? args;

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  late String _code = widget.args == null ? '482619' : '';
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

  Future<void> _resend() async {
    final args = widget.args;
    if (args == null) return;
    setState(() => _secondsLeft = 30);
    _startTimer();
    try {
      await ref.read(backendProvider).sendOtp(args.phone);
    } on BackendException catch (e) {
      if (mounted) setState(() => _error = authErrorText(context, e.code));
    }
  }

  Future<void> _verify([String? code]) async {
    final args = widget.args;
    final value = code ?? _code;
    if (value.length != 6 || _verifying) return;
    if (args == null) {
      context.go('/home');
      return;
    }
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      await ref.read(backendProvider).verifyOtp(args.phone, value, signUp: args.signUp);
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
    final phone = formatPhone(widget.args?.phone ?? Sample.riderPhone);
    final demo = widget.args != null && ref.watch(backendProvider).isDemo;
    final resendText = _secondsLeft > 0 ? t.resendIn(formatDuration(_secondsLeft)) : t.resendNow;
    return IyoScreen(
      header: IyoAppHeader(flowLabel: t.flowAccount('06')),
      heading: IyoPageHeading(title: t.verifyTitle, subtitle: t.verifySubtitle(phone)),
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
                onPressed: _secondsLeft == 0 ? _resend : null,
                minHitSize: 0,
                semanticLabel: resendText,
                child: IyoText(resendText, color: IyoPalette.charcoal),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: IyoPressable(
                onPressed: context.pop,
                minHitSize: 0,
                semanticLabel: '${t.wrongNumber} ${t.changeIt}',
                child: IyoText('${t.wrongNumber} ${t.changeIt}', color: IyoPalette.charcoal),
              ),
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
