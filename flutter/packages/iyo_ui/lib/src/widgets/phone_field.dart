import 'package:flutter/material.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'forms.dart';
import 'primitives.dart';

/// Mobile number with a country picker. The flag button opens a searchable list of African
/// countries; typing or pasting "+236…" / "00236…" switches the country by itself.
/// [onChanged] reports the parsed number (country + national digits, `isValid`, `e164`).
class IyoPhoneField extends StatefulWidget {
  const IyoPhoneField({
    super.key,
    required this.onChanged,
    this.label,
    this.error,
    this.initialCountry,
    this.placeholder,
    this.initialValue,
    this.pickerTitle,
    this.searchHint,
    this.countryButtonLabel,
  });

  final ValueChanged<ParsedPhone> onChanged;
  final String? label;
  final String? error;

  /// Defaults to the phone's region (Central African Republic when unknown).
  final PhoneCountry? initialCountry;

  /// Example number; defaults to a grouped example of the right length for the country.
  final String? placeholder;

  /// A number to start with (design previews); its code picks the country.
  final String? initialValue;

  /// Picker texts; default to English or French by the app's language.
  final String? pickerTitle;
  final String? searchHint;
  final String? countryButtonLabel;

  @override
  State<IyoPhoneField> createState() => _IyoPhoneFieldState();
}

class _IyoPhoneFieldState extends State<IyoPhoneField> {
  late PhoneCountry _country = widget.initialCountry ?? defaultPhoneCountry();
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialValue;
    if (initial != null) {
      final p = parsePhone(initial, country: _country);
      _country = p.country;
      _controller.text = groupNational(p.national);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changed(String text) {
    final parsed = parsePhone(text, country: _country);
    final typedCode = text.trim().startsWith('+') || text.trim().startsWith('00');
    if (parsed.country != _country || (typedCode && parsed.national.isNotEmpty)) {
      // "+236 75…" or "23675…": the code moves into the country button, the field keeps
      // only the national digits.
      setState(() => _country = parsed.country);
      _controller.value = TextEditingValue(
        text: parsed.national,
        selection: TextSelection.collapsed(offset: parsed.national.length),
      );
    }
    widget.onChanged(parsed);
  }

  Future<void> _pick() async {
    final picked = await showModalBottomSheet<PhoneCountry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: IyoPalette.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(IyoRadii.lg)),
      ),
      builder:
          (context) => _CountrySheet(
            selected: _country,
            title:
                widget.pickerTitle ?? _fr(context, 'Choose your country', 'Choisissez votre pays'),
            searchHint:
                widget.searchHint ?? _fr(context, 'Search a country or code', 'Pays ou indicatif'),
          ),
    );
    if (picked == null || !mounted) return;
    setState(() => _country = picked);
    widget.onChanged(parsePhone(_controller.text, country: picked));
  }

  String get _example {
    final n = _country.lengths.last;
    return groupNational(List.generate(n, (i) => '${(7 + i) % 10}').join());
  }

  @override
  Widget build(BuildContext context) {
    return IyoTextField(
      label: widget.label,
      error: widget.error,
      controller: _controller,
      placeholder: widget.placeholder ?? _example,
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      onChanged: _changed,
      leading: IyoPressable(
        onPressed: _pick,
        minHitSize: 0,
        semanticLabel:
            '${widget.countryButtonLabel ?? _fr(context, 'Country code', 'Indicatif du pays')}: '
            '${_country.name(_lang(context))} +${_country.dial}',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_country.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            IyoText('+${_country.dial}', variant: IyoTextVariant.input),
            const SizedBox(width: 2),
            const IyoIcon(LucideIcons.chevronDown, size: 14),
          ],
        ),
      ),
    );
  }
}

String _lang(BuildContext context) => Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';

String _fr(BuildContext context, String en, String fr) => _lang(context) == 'fr' ? fr : en;

class _CountrySheet extends StatefulWidget {
  const _CountrySheet({required this.selected, required this.title, required this.searchHint});

  final PhoneCountry selected;
  final String title;
  final String searchHint;

  @override
  State<_CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<_CountrySheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final lang = _lang(context);
    final q = _query.trim().toLowerCase().replaceFirst('+', '');
    final countries = [
      for (final c in africanCountries)
        if (q.isEmpty ||
            c.nameEn.toLowerCase().contains(q) ||
            c.nameFr.toLowerCase().contains(q) ||
            c.dial.startsWith(q) ||
            c.iso.toLowerCase() == q)
          c,
    ];
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            IyoSpacing.lg,
            IyoSpacing.lg,
            IyoSpacing.lg,
            MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IyoText(widget.title, variant: IyoTextVariant.title),
              const SizedBox(height: IyoSpacing.md),
              IyoTextField(
                placeholder: widget.searchHint,
                leading: const IyoIcon(LucideIcons.search, size: IyoSizes.iconSmall),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: IyoSpacing.sm),
              Expanded(
                child: ListView.builder(
                  itemCount: countries.length,
                  itemBuilder: (context, i) {
                    final c = countries[i];
                    final selected = c == widget.selected;
                    return IyoPressable(
                      onPressed: () => Navigator.pop(context, c),
                      selected: selected,
                      semanticLabel: '${c.name(lang)} +${c.dial}',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Text(c.flag, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: IyoSpacing.md),
                            Expanded(child: IyoText(c.name(lang), variant: IyoTextVariant.body)),
                            IyoText(
                              '+${c.dial}',
                              variant: IyoTextVariant.body,
                              color: IyoPalette.textSecondary,
                            ),
                            if (selected) ...[
                              const SizedBox(width: IyoSpacing.sm),
                              const IyoIcon(LucideIcons.check, size: IyoSizes.iconSmall),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
