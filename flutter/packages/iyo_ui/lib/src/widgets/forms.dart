import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/iyo_theme.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'primitives.dart';

/// Figma "Form field": 11 px Medium label, control, 10 px helper; gap 6.
class IyoFormField extends StatelessWidget {
  const IyoFormField({super.key, this.label, this.helper, this.error, required this.child});

  final String? label;

  /// Helper text under the control ("We'll text you a 6-digit verification code.").
  final String? helper;

  /// Error text; replaces the helper and turns red.
  final String? error;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null) ...[
          IyoText(label!, variant: IyoTextVariant.captionMedium, color: IyoPalette.charcoal),
          const SizedBox(height: 6),
        ],
        child,
        if (error != null) ...[
          const SizedBox(height: 6),
          Semantics(
            liveRegion: true,
            child: IyoText(error!, variant: IyoTextVariant.helper, color: IyoPalette.danger),
          ),
        ] else if (helper != null) ...[
          const SizedBox(height: 6),
          IyoText(helper!, variant: IyoTextVariant.helper, color: IyoPalette.textSecondary),
        ],
      ],
    );
  }
}

/// Input box decoration shared by text, select and PIN fields: 1 px border, 2 px accent when
/// focused, 2 px danger on error, radius 10.
BoxDecoration _boxDecoration(
  BuildContext context, {
  required bool focused,
  required bool error,
  bool enabled = true,
}) {
  final color = error ? IyoPalette.danger : (focused ? context.iyo.accent : IyoPalette.border);
  return BoxDecoration(
    color: enabled ? IyoPalette.white : IyoPalette.surface,
    borderRadius: BorderRadius.circular(IyoRadii.md),
    border: Border.all(color: color, width: focused || error ? 2 : 1),
  );
}

/// Figma "Input": min 48 px, padding 13, radius 10, 1 px #E9E9E6 border,
/// 2 px accent border when focused, 13 px Regular value.
class IyoTextField extends StatefulWidget {
  const IyoTextField({
    super.key,
    this.label,
    this.helper,
    this.error,
    this.prefix,
    this.placeholder,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.multiline = false,
    this.leading,
    this.trailing,
    this.autofillHints,
    this.highlighted = false,
    this.obscureText = false,
    this.revealLabel = 'Show password',
    this.readOnly = false,
    this.onTap,
  });

  final String? label;
  final String? helper;
  final String? error;

  /// Fixed text before the input, e.g. "+237".
  final String? prefix;
  final String? placeholder;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool multiline;
  final Widget? leading;
  final Widget? trailing;
  final Iterable<String>? autofillHints;

  /// Draw the 2 px accent border even when not focused (the field the flow is about,
  /// e.g. Destination on "Plan your ride").
  final bool highlighted;

  /// Password entry with a show / hide toggle.
  final bool obscureText;
  final String revealLabel;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  State<IyoTextField> createState() => _IyoTextFieldState();
}

class _IyoTextFieldState extends State<IyoTextField> {
  final _focus = FocusNode();
  TextEditingController? _ownController;
  bool _revealed = false;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController(text: widget.initialValue));

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus || widget.highlighted;
    final hasError = widget.error != null;
    // Keep content from shifting when the border thickens.
    final inset = 13.0 - (focused || hasError ? 1 : 0);
    return IyoFormField(
      label: widget.label,
      helper: widget.helper,
      error: widget.error,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        constraints: BoxConstraints(minHeight: widget.multiline ? 88 : IyoSizes.inputMinHeight),
        padding: EdgeInsets.symmetric(horizontal: inset),
        decoration: _boxDecoration(
          context,
          focused: focused,
          error: hasError,
          enabled: widget.enabled,
        ),
        child: Row(
          crossAxisAlignment:
              widget.multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            if (widget.leading != null) ...[widget.leading!, const SizedBox(width: IyoSpacing.sm)],
            if (widget.prefix != null) ...[
              IyoText(widget.prefix!, variant: IyoTextVariant.input),
              const SizedBox(width: IyoSpacing.sm),
            ],
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                onTap: widget.onTap,
                obscureText: widget.obscureText && !_revealed,
                obscuringCharacter: '•',
                onChanged: widget.onChanged,
                keyboardType: widget.multiline ? TextInputType.multiline : widget.keyboardType,
                textInputAction: widget.textInputAction,
                maxLines: widget.multiline ? 5 : 1,
                minLines: widget.multiline ? 3 : 1,
                autofillHints: widget.autofillHints,
                style: IyoTextVariant.input.style.copyWith(color: IyoPalette.ink),
                cursorColor: IyoPalette.ink,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintText: widget.placeholder,
                  hintStyle: IyoTextVariant.input.style.copyWith(color: IyoPalette.muted),
                  semanticCounterText: '',
                ),
              ),
            ),
            if (widget.obscureText)
              IyoPressable(
                onPressed: () => setState(() => _revealed = !_revealed),
                semanticLabel: widget.revealLabel,
                selected: _revealed,
                child: IyoIcon(
                  _revealed ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: IyoSizes.iconSmall,
                ),
              ),
            if (widget.trailing != null) ...[
              const SizedBox(width: IyoSpacing.sm),
              widget.trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Square 14 px checkbox (ink when checked) with an optional inline label, as in the sign-up
/// terms row and the trusted-contact picker.
class IyoCheckbox extends StatelessWidget {
  const IyoCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.labelVariant = IyoTextVariant.body,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;
  final IyoTextVariant labelVariant;

  @override
  Widget build(BuildContext context) {
    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: value ? IyoPalette.charcoal : IyoPalette.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: value ? IyoPalette.charcoal : IyoPalette.muted, width: 1.2),
      ),
      child: value ? const Icon(LucideIcons.check, size: 10, color: IyoPalette.white) : null,
    );
    return Semantics(
      checked: value,
      label: label,
      excludeSemantics: true,
      child: IyoPressable(
        onPressed: () => onChanged(!value),
        isButton: false,
        pressedOpacity: 0.8,
        minHitSize: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              box,
              if (label != null) ...[
                const SizedBox(width: 6),
                Flexible(child: IyoText(label!, variant: labelVariant)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class IyoSelectOption<T> {
  const IyoSelectOption({required this.value, required this.label, this.description});

  final T value;
  final String label;
  final String? description;
}

/// Looks like a text field with a chevron; opens a bottom sheet list of options.
class IyoSelectField<T> extends StatelessWidget {
  const IyoSelectField({
    super.key,
    this.label,
    this.helper,
    this.error,
    this.placeholder,
    required this.value,
    required this.options,
    required this.onChanged,
    this.sheetTitle,
    this.enabled = true,
  });

  final String? label;
  final String? helper;
  final String? error;
  final String? placeholder;
  final T? value;
  final List<IyoSelectOption<T>> options;
  final ValueChanged<T> onChanged;

  /// Title of the picker sheet; defaults to the label.
  final String? sheetTitle;
  final bool enabled;

  Future<void> _open(BuildContext context) async {
    final picked = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: IyoPalette.white,
      barrierColor: IyoPalette.overlay,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(IyoRadii.xl)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    IyoSpacing.xxl,
                    0,
                    IyoSpacing.xxl,
                    IyoSpacing.md,
                  ),
                  child: IyoText(sheetTitle ?? label ?? '', variant: IyoTextVariant.cardTitle),
                ),
                for (final option in options)
                  IyoPressable(
                    onPressed: () => Navigator.of(context).pop(option.value),
                    semanticLabel: option.label,
                    selected: option.value == value,
                    pressedOpacity: 0.6,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 52),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: IyoSpacing.xxl,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IyoText(option.label, variant: IyoTextVariant.rowTitle),
                                  if (option.description != null)
                                    IyoText(
                                      option.description!,
                                      variant: IyoTextVariant.caption,
                                      color: IyoPalette.textSecondary,
                                    ),
                                ],
                              ),
                            ),
                            if (option.value == value)
                              const IyoIcon(LucideIcons.check, size: IyoSizes.iconSmall),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: IyoSpacing.sm),
              ],
            ),
          ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    IyoSelectOption<T>? selected;
    for (final o in options) {
      if (o.value == value) selected = o;
    }
    final hasError = error != null;
    return IyoFormField(
      label: label,
      helper: helper,
      error: error,
      child: IyoPressable(
        onPressed: () => _open(context),
        disabled: !enabled,
        semanticLabel: '${label ?? ''}, ${selected?.label ?? placeholder ?? ''}',
        pressedOpacity: 0.9,
        child: Container(
          constraints: const BoxConstraints(minHeight: IyoSizes.inputMinHeight),
          padding: EdgeInsets.symmetric(horizontal: hasError ? 12 : 13),
          decoration: _boxDecoration(context, focused: false, error: hasError, enabled: enabled),
          child: Row(
            children: [
              Expanded(
                child: IyoText(
                  selected?.label ?? placeholder ?? '',
                  variant: IyoTextVariant.input,
                  color: selected == null ? IyoPalette.muted : IyoPalette.ink,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: IyoSpacing.sm),
              const IyoIcon(LucideIcons.chevronDown, size: IyoSizes.iconSmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// Switch with the accent track when on. No Figma frame shows one; styled to match buttons.
class IyoToggle extends StatelessWidget {
  const IyoToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.enabled = true,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  /// Row label; when given the whole row is tappable.
  final String? label;
  final String? description;
  final bool enabled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    const trackW = 44.0, trackH = 26.0, knob = 20.0;
    final track = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: trackW,
      height: trackH,
      padding: const EdgeInsets.all(3),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: value ? context.iyo.accent : IyoPalette.border,
        borderRadius: BorderRadius.circular(trackH / 2),
      ),
      child: Container(
        width: knob,
        height: knob,
        decoration: const BoxDecoration(
          color: IyoPalette.white,
          shape: BoxShape.circle,
          boxShadow: IyoShadows.card,
        ),
      ),
    );

    return Semantics(
      toggled: value,
      enabled: enabled,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      child: IyoPressable(
        onPressed: () => onChanged(!value),
        disabled: !enabled,
        isButton: false,
        pressedOpacity: 1,
        child:
            label == null
                ? track
                : Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IyoText(label!, variant: IyoTextVariant.rowTitle),
                          if (description != null)
                            IyoText(
                              description!,
                              variant: IyoTextVariant.caption,
                              color: IyoPalette.textSecondary,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: IyoSpacing.md),
                    track,
                  ],
                ),
      ),
    );
  }
}

/// Digit entry backed by one hidden TextField, so paste, SMS autofill and backspace behave
/// natively. `boxes` = one 58 px box per digit (OTP); otherwise digits spaced in one field (PIN).
class _CodeInput extends StatefulWidget {
  const _CodeInput({
    required this.length,
    required this.boxes,
    required this.value,
    required this.onChanged,
    this.onCompleted,
    this.label,
    this.helper,
    this.error,
    this.autofocus = false,
    this.obscure = false,
    this.oneTimeCode = false,
  });

  final int length;
  final bool boxes;
  final String value;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final String? label;
  final String? helper;
  final String? error;
  final bool autofocus;
  final bool obscure;
  final bool oneTimeCode;

  @override
  State<_CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<_CodeInput> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant _CodeInput old) {
    super.didUpdateWidget(old);
    if (widget.value != _controller.text) _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _handle(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    final clipped = digits.length > widget.length ? digits.substring(0, widget.length) : digits;
    widget.onChanged(clipped);
    if (clipped.length == widget.length) widget.onCompleted?.call(clipped);
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final hasError = widget.error != null;
    final value = widget.value;
    final active = value.length < widget.length ? value.length : widget.length - 1;
    String shown(int i) {
      if (i >= value.length) return '';
      return widget.obscure ? '•' : value[i];
    }

    final Widget visual;
    if (widget.boxes) {
      visual = Row(
        children: [
          for (var i = 0; i < widget.length; i++) ...[
            if (i > 0) const SizedBox(width: IyoSpacing.sm),
            Expanded(
              child: Container(
                height: IyoSizes.digitHeight,
                alignment: Alignment.center,
                decoration: _boxDecoration(
                  context,
                  focused: focused && i == active,
                  error: hasError,
                ),
                child: IyoText(shown(i), variant: IyoTextVariant.digit, color: IyoPalette.black),
              ),
            ),
          ],
        ],
      );
    } else {
      visual = Container(
        constraints: const BoxConstraints(minHeight: IyoSizes.inputMinHeight),
        padding: EdgeInsets.symmetric(horizontal: focused || hasError ? 12 : 13),
        decoration: _boxDecoration(context, focused: focused, error: hasError),
        child: Row(
          children: [
            for (var i = 0; i < widget.length; i++) ...[
              if (i > 0) const SizedBox(width: 24),
              SizedBox(
                width: 12,
                child: IyoText(
                  i < value.length ? shown(i) : '–',
                  variant: IyoTextVariant.input,
                  color: i < value.length ? IyoPalette.ink : IyoPalette.muted,
                  align: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return IyoFormField(
      label: widget.label,
      helper: widget.helper,
      error: widget.error,
      child: Stack(
        children: [
          ExcludeSemantics(child: visual),
          // The real input covers the visual but is invisible; taps focus it directly.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                autofocus: widget.autofocus,
                onChanged: _handle,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                autofillHints: widget.oneTimeCode ? const [AutofillHints.oneTimeCode] : null,
                showCursor: false,
                enableInteractiveSelection: false,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  labelText: widget.label,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 6-digit SMS verification code, one box per digit (Figma 2005:50088).
class IyoOtpInput extends StatelessWidget {
  const IyoOtpInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.onCompleted,
    this.label,
    this.helper,
    this.error,
    this.autofocus = false,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final String? label;
  final String? helper;
  final String? error;
  final bool autofocus;

  @override
  Widget build(BuildContext context) => _CodeInput(
    length: 6,
    boxes: true,
    oneTimeCode: true,
    value: value,
    onChanged: onChanged,
    onCompleted: onCompleted,
    label: label,
    helper: helper,
    error: error,
    autofocus: autofocus,
  );
}

/// 4-digit pickup PIN entered by the driver (Figma 2005:51465).
class IyoPinInput extends StatelessWidget {
  const IyoPinInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.onCompleted,
    this.label,
    this.helper,
    this.error,
    this.obscure = false,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;
  final String? label;
  final String? helper;
  final String? error;
  final bool obscure;

  @override
  Widget build(BuildContext context) => _CodeInput(
    length: 4,
    boxes: false,
    value: value,
    onChanged: onChanged,
    onCompleted: onCompleted,
    label: label,
    helper: helper,
    error: error,
    obscure: obscure,
  );
}

class IyoSegment<T> {
  const IyoSegment({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Row of equal-width options; the active one is filled with the accent colour.
/// `large` = 56 px service selector (Ride / Rent a car); otherwise 40 px view filter (All / Unread).
class IyoSegmentedTabs<T> extends StatelessWidget {
  const IyoSegmentedTabs({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.large = false,
  });

  final List<IyoSegment<T>> options;
  final T value;
  final ValueChanged<T> onChanged;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final iyo = context.iyo;
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) SizedBox(width: large ? 10 : IyoSpacing.sm),
          Expanded(
            child: Builder(
              builder: (context) {
                final option = options[i];
                final active = option.value == value;
                final variant =
                    large
                        ? IyoTextVariant.subheading
                        : (active ? IyoTextVariant.buttonSmall : IyoTextVariant.body);
                return IyoPressable(
                  onPressed: () => onChanged(option.value),
                  semanticLabel: option.label,
                  selected: active,
                  child: Container(
                    height: large ? IyoSizes.serviceOptionHeight : IyoSizes.buttonSmallHeight,
                    padding: EdgeInsets.symmetric(
                      // The service selector hugs its icon to the left edge (Figma: 2 px).
                      horizontal: large ? 2 : IyoSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: active ? iyo.accent : IyoPalette.surface,
                      borderRadius: BorderRadius.circular(IyoRadii.md),
                    ),
                    child: Row(
                      mainAxisAlignment: large ? MainAxisAlignment.start : MainAxisAlignment.center,
                      children: [
                        if (option.icon != null) ...[
                          IyoIcon(option.icon!, color: active ? iyo.onAccent : IyoPalette.ink),
                          const SizedBox(width: 9),
                        ],
                        Flexible(
                          child: IyoText(
                            option.label,
                            variant: variant,
                            color: active ? iyo.onAccent : IyoPalette.ink,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
