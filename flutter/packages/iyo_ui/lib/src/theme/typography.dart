import 'package:flutter/painting.dart';

/// Poppins is the only typeface (bundled in this package, weights 400–800).
TextStyle _poppins(FontWeight weight, double size, double lineHeight, {double? letterSpacing}) =>
    TextStyle(
      fontFamily: 'Poppins',
      package: 'iyo_ui',
      fontWeight: weight,
      fontSize: size,
      height: lineHeight / size,
      letterSpacing: letterSpacing,
      leadingDistribution: TextLeadingDistribution.even,
    );

const FontWeight _regular = FontWeight.w400;
const FontWeight _medium = FontWeight.w500;
const FontWeight _semibold = FontWeight.w600;
const FontWeight _bold = FontWeight.w700;

/// Text variants measured from the 390 × 844 Figma frames (line height 1.5 unless noted).
enum IyoTextVariant {
  /// Welcome / onboarding headline.
  hero,

  /// Page heading title, e.g. "Where to, Aïcha?".
  title,

  /// Profile name in identity cards (line height 1.6).
  heading,

  /// Information card title, e.g. "You're in a busy area".
  cardTitle,

  /// Person name next to a portrait.
  subheading,

  /// Section headings ("Today") and service option labels.
  bodyStrong,

  /// List row titles.
  rowTitle,

  /// Titles inside notification / journey cards (14 Medium).
  listTitle,

  /// Receipt total, e.g. "2 500 FCFA" on the arrival screen.
  amountHero,

  /// Balance figures, e.g. wallet ride credit.
  amount,

  /// Text field value.
  input,

  /// Page subtitles, chat messages, card body copy.
  body,

  /// Row subtitles, footnotes.
  caption,

  /// Form field labels and inline links.
  captionMedium,

  /// Field helper text.
  helper,

  /// Action tile labels.
  tileLabel,

  /// Status pills, e.g. "YOUR PICKUP PIN · 4826" (rendered uppercase).
  status,

  /// Timestamps under chat bubbles and notification cards.
  micro,

  /// Flow label in the header, e.g. "RIDER · 01" (rendered uppercase).
  label,
  tab,
  tabActive,
  button,
  buttonSmall,

  /// One digit of an OTP / PIN box.
  digit,

  /// Initials inside a 56 px avatar.
  avatar,
  wordmark;

  bool get uppercase => this == status || this == label;

  TextStyle get style => switch (this) {
    hero => _poppins(_semibold, 36, 44, letterSpacing: -0.5),
    title => _poppins(_semibold, 24, 36),
    heading => _poppins(_semibold, 16, 25.6),
    cardTitle => _poppins(_semibold, 15, 22.5),
    subheading => _poppins(_semibold, 14, 21),
    bodyStrong => _poppins(_semibold, 13, 19.5),
    rowTitle => _poppins(_medium, 13, 19.5),
    listTitle => _poppins(_medium, 14, 21),
    amountHero => _poppins(_semibold, 36, 44),
    amount => _poppins(_semibold, 32, 40),
    input => _poppins(_regular, 13, 19.5),
    body => _poppins(_regular, 12, 18),
    caption => _poppins(_regular, 11, 16.5),
    captionMedium => _poppins(_medium, 11, 16.5),
    helper => _poppins(_regular, 10, 15),
    tileLabel => _poppins(_medium, 10, 15),
    status => _poppins(_medium, 10, 15),
    micro => _poppins(_regular, 9, 13.5),
    label => _poppins(_medium, 9, 13.5, letterSpacing: 0.3),
    tab => _poppins(_regular, 9, 13.5),
    tabActive => _poppins(_semibold, 9, 13.5),
    button => _poppins(_semibold, 15, 22.5),
    buttonSmall => _poppins(_semibold, 12, 18),
    digit => _poppins(_medium, 23, 30),
    avatar => _poppins(_semibold, 19, 28.5),
    wordmark => _poppins(_bold, 17, 25.5),
  };
}
