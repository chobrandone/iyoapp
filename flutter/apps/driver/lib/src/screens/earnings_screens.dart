import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../sample/sample_data.dart';
import '../widgets/driver_widgets.dart';
import 'home_screens.dart';

/// Trips of the last ~13 months (charts for every period plus last year's comparison).
final tripHistoryProvider = FutureProvider.autoDispose<List<CompletedTrip>>((ref) {
  final now = DateTime.now();
  return ref.watch(backendProvider).tripsSince(DateTime(now.year - 1, now.month));
});

final payoutsProvider = FutureProvider.autoDispose<List<Payout>>(
  (ref) => ref.watch(backendProvider).payouts(),
);

/// "MTN MoMo •••• 4455" for a payout destination.
String payoutAccount(BuildContext context, PaymentMethodType method, String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  final last = digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
  return '${paymentLabel(context, method)} •••• $last';
}

/// The next Monday after [from] (weekly payouts).
DateTime nextMonday(DateTime from) {
  final d = DateTime(from.year, from.month, from.day);
  return d.add(Duration(days: 8 - d.weekday));
}

/// DRIVER — Earnings and payout history (Figma 2025:698).
class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key, this.preview = false});

  final bool preview;

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  var _period = EarningsPeriod.week;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final preview = widget.preview;
    final now = preview ? DateTime(2026, 10, 15, 9) : DateTime.now();
    final trips = preview ? null : ref.watch(tripHistoryProvider).value;
    final payouts = preview ? _samplePayouts : ref.watch(payoutsProvider).value ?? const [];
    final account = preview ? null : ref.watch(driverAccountProvider).value;

    final EarningsSummary summary;
    if (preview && _period == EarningsPeriod.week) {
      final (start, end) = EarningsSummary.range(EarningsPeriod.week, now);
      summary = EarningsSummary(
        period: EarningsPeriod.week,
        start: start,
        end: end,
        total: DriverSample.weekTotal,
        trips: DriverSample.weekTrips,
        driveSeconds: DriverSample.weekDriveSeconds,
        buckets: DriverSample.weekBuckets,
        currentBucket: 3,
        changePercent: 12.4,
      );
    } else {
      summary = EarningsSummary.from(trips ?? const [], _period, now);
    }

    final labels = switch (_period) {
      EarningsPeriod.week => t.weekdayLetters.split(','),
      EarningsPeriod.month => [for (var i = 1; i <= summary.buckets.length; i++) t.weekN('$i')],
      EarningsPeriod.year => t.monthLetters.split(','),
    };
    final soFar = switch (_period) {
      EarningsPeriod.week => t.weekSoFar,
      EarningsPeriod.month => t.monthSoFar,
      EarningsPeriod.year => t.yearSoFar,
    };
    final change = summary.changePercent;

    final payTo =
        preview
            ? DriverSample.payoutAccount
            : account?.payoutMethod == null || account?.payoutPhone == null
            ? t.notSet
            : payoutAccount(context, account!.payoutMethod!, account.payoutPhone!);
    // Next payout: everything earned since the last paid period.
    final lastEnd = payouts.isEmpty ? null : payouts.first.periodEnd;
    final pending =
        preview
            ? DriverSample.weekTotal
            : (trips ?? const <CompletedTrip>[])
                .where(
                  (x) =>
                      lastEnd == null ||
                      x.completedAt.isAfter(lastEnd.add(const Duration(days: 1))),
                )
                .fold(0, (s, x) => s + x.earnings);

    return IyoScreen(
      inTabs: true,
      header: DriverHeader(flowLabel: t.flowPlain),
      heading: IyoPageHeading(
        title: t.earnTitle,
        subtitle: t.earnSubtitle(
          formatPeriodRange(context, summary.start, summary.end.subtract(const Duration(days: 1))),
        ),
        compact: true,
      ),
      footer: [
        IyoButton(
          label: t.viewPayoutDetails,
          disabled: payouts.isEmpty,
          onPressed:
              payouts.isEmpty
                  ? null
                  : () =>
                      preview
                          ? context.push('/design/payout')
                          : context.push('/payout/${payouts.first.id}'),
        ),
      ],
      children: [
        IyoSegmentedTabs<EarningsPeriod>(
          value: _period,
          onChanged: (p) => setState(() => _period = p),
          options: [
            IyoSegment(value: EarningsPeriod.week, label: t.periodWeek),
            IyoSegment(value: EarningsPeriod.month, label: t.periodMonth),
            IyoSegment(value: EarningsPeriod.year, label: t.periodYear),
          ],
        ),
        IyoCard(
          children: [
            IyoText(soFar, variant: IyoTextVariant.caption, color: IyoPalette.textSecondary),
            IyoText(
              formatFcfa(summary.total),
              variant: IyoTextVariant.amount,
              style: const TextStyle(height: 1.5),
            ),
            Row(
              children: [
                Expanded(
                  child: IyoText(
                    t.tripsDriving(
                      tripsLabel(context, summary.trips),
                      hoursMinutes(summary.driveSeconds),
                    ),
                    color: IyoPalette.textSecondary,
                  ),
                ),
                if (change != null)
                  IyoText(
                    '${change >= 0 ? '+' : '−'}${change.abs().toStringAsFixed(1)}%',
                    variant: IyoTextVariant.rowTitle,
                  ),
              ],
            ),
            EarningsChart(values: summary.buckets, labels: labels, current: summary.currentBucket),
          ],
        ),
        IyoCard(
          children: [
            Row(
              children: [
                Expanded(child: IyoText(t.nextPayout, variant: IyoTextVariant.subheading)),
                IyoText(formatFcfa(pending), variant: IyoTextVariant.heading),
              ],
            ),
            IyoText(
              t.nextPayoutDetail(formatLongDay(context, nextMonday(now)), payTo),
              variant: IyoTextVariant.caption,
              color: IyoPalette.textSecondary,
            ),
          ],
        ),
        SectionTitle(t.payoutHistory),
        if (payouts.isEmpty)
          Footnote(t.noPayoutsYet)
        else
          IyoCard(
            children: [
              for (final (i, p) in payouts.take(4).indexed) ...[
                RichRow(
                  title: '${formatDayMonth(context, p.requestedAt)} · ${p.reference}',
                  aside: formatFcfa(p.amount),
                  chevron: true,
                  subtitle: switch (p.status) {
                    PayoutStatus.paid => t.paidTo(payoutAccount(context, p.method, p.phone)),
                    PayoutStatus.failed => t.payoutFailed(p.failureReason ?? ''),
                    _ => t.payoutPending(payoutAccount(context, p.method, p.phone)),
                  },
                  onPressed:
                      () =>
                          preview
                              ? context.push('/design/payout')
                              : context.push('/payout/${p.id}'),
                ),
                if (i == 0) Align(alignment: Alignment.centerLeft, child: payoutBadge(context, p)),
              ],
            ],
          ),
      ],
    );
  }

  static final _samplePayouts = [
    Payout(
      id: 'PO-071',
      amount: 132800,
      method: PaymentMethodType.mtnMomo,
      phone: '+237682334455',
      status: PayoutStatus.paid,
      requestedAt: DateTime(2026, 10, 12, 8),
      periodStart: DateTime(2026, 10, 5),
      periodEnd: DateTime(2026, 10, 11),
      paidAt: DateTime(2026, 10, 13, 9, 2),
      providerReference: 'MOMO-PO071',
    ),
    Payout(
      id: 'PO-064',
      amount: 126500,
      method: PaymentMethodType.mtnMomo,
      phone: '+237682334455',
      status: PayoutStatus.paid,
      requestedAt: DateTime(2026, 10, 5, 8),
      periodStart: DateTime(2026, 9, 28),
      periodEnd: DateTime(2026, 10, 4),
      paidAt: DateTime(2026, 10, 6, 9, 10),
    ),
  ];
}

IyoBadge payoutBadge(BuildContext context, Payout p) {
  final t = context.t;
  return switch (p.status) {
    PayoutStatus.paid => IyoBadge(t.statusPaid, tone: IyoBadgeTone.success),
    PayoutStatus.failed => IyoBadge(t.statusFailed, tone: IyoBadgeTone.danger),
    _ => IyoBadge(t.statusPending),
  };
}

/// DRIVER — Payout details (Figma 2025:757).
class PayoutDetailsScreen extends ConsumerWidget {
  const PayoutDetailsScreen({super.key, this.payoutId});

  /// Null: Figma sample content.
  final String? payoutId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final preview = payoutId == null;
    final Payout? payout =
        preview
            ? _EarningsScreenState._samplePayouts.first
            : ref.watch(payoutsProvider).value?.where((p) => p.id == payoutId).firstOrNull;
    final trips = preview ? null : ref.watch(tripHistoryProvider).value;
    final profile = preview ? null : ref.watch(profileProvider).value;
    if (payout == null) {
      return IyoScreen(
        header: DriverHeader(flowLabel: t.flowPlain),
        children: const [IyoSkeletonRow()],
      );
    }
    final ref_ = preview ? 'PO-071' : payout.reference;
    final start = payout.periodStart ?? payout.requestedAt.subtract(const Duration(days: 7));
    final end = payout.periodEnd ?? payout.requestedAt;
    final breakdown =
        preview
            ? const PayoutBreakdown(
              trips: 46,
              fares: 158400,
              tips: 3500,
              serviceFees: 31600,
              rentalHandovers: 2500,
            )
            : PayoutBreakdown.of(
              (trips ?? const <CompletedTrip>[])
                  .where(
                    (x) =>
                        !x.completedAt.isBefore(start) &&
                        x.completedAt.isBefore(end.add(const Duration(days: 1))),
                  )
                  .toList(),
            );
    final account = payoutAccount(context, payout.method, payout.phone);
    final name = preview ? DriverSample.driverName : profile?.fullName ?? '';

    Widget line(String label, String value, {bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(
            child: IyoText(
              label,
              variant: strong ? IyoTextVariant.bodyStrong : IyoTextVariant.body,
              color: strong ? IyoPalette.ink : IyoPalette.textSecondary,
            ),
          ),
          IyoText(
            value,
            variant: strong ? IyoTextVariant.bodyStrong : IyoTextVariant.body,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );

    Widget step(String title, String body, DateTime? when, {bool last = false}) => Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 19),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 3,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: when == null ? IyoPalette.muted : IyoPalette.ink,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(child: IyoText(title, variant: IyoTextVariant.rowTitle)),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: IyoText(
                  body,
                  variant: IyoTextVariant.helper,
                  color: IyoPalette.textSecondary,
                ),
              ),
              if (when != null)
                IyoText(
                  formatDayMonth(context, when),
                  variant: IyoTextVariant.caption,
                  color: IyoPalette.textSecondary,
                ),
            ],
          ),
        ],
      ),
    );

    final sent = payout.status == PayoutStatus.paid ? payout.paidAt : null;
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flowPlain),
      heading: IyoPageHeading(
        title: t.payoutTitle,
        subtitle: t.payoutSubtitle(ref_, formatPeriodRange(context, start, end)),
        onBack: context.pop,
        compact: true,
      ),
      footer: [
        IyoButton(
          label: t.downloadStatement,
          icon: LucideIcons.download,
          onPressed: () => _shareStatement(context, payout, ref_, breakdown, account),
        ),
      ],
      children: [
        IyoCard(
          children: [
            Align(alignment: Alignment.centerLeft, child: payoutBadge(context, payout)),
            IyoText(
              formatFcfa(payout.amount),
              variant: IyoTextVariant.amount,
              style: const TextStyle(height: 1.5),
            ),
            IyoText(
              // "Sent" is when the transfer left iyodriver; delivery is on the timeline.
              payout.status == PayoutStatus.pending
                  ? t.requestedOn(formatLongDate(context, payout.requestedAt))
                  : t.sentOn(formatLongDate(context, payout.requestedAt)),
              variant: IyoTextVariant.caption,
              color: IyoPalette.textSecondary,
            ),
          ],
        ),
        IyoCard(
          children: [
            IyoText(t.payoutBreakdown, variant: IyoTextVariant.cardTitle),
            line(
              t.rideFaresLine(tripsLabel(context, breakdown.trips)),
              formatFcfa(breakdown.fares),
            ),
            if (breakdown.rentalHandovers > 0)
              line(t.rentalHandoverEarnings, formatFcfa(breakdown.rentalHandovers)),
            line(t.tipsLine, formatFcfa(breakdown.tips)),
            line(t.serviceFeesLine, '−${formatFcfa(breakdown.serviceFees)}'),
            line(t.netPayout, formatFcfa(breakdown.net), strong: true),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IyoText(account, variant: IyoTextVariant.rowTitle),
            const SizedBox(height: 2),
            IyoText(
              t.mobileMoneyTransfer(name),
              variant: IyoTextVariant.caption,
              color: IyoPalette.textSecondary,
            ),
          ],
        ),
        IyoCard(
          children: [
            IyoText(t.transferTimeline, variant: IyoTextVariant.cardTitle),
            step(t.tlCreated, t.tlCreatedBody(formatTime(payout.requestedAt)), payout.requestedAt),
            step(
              t.tlSent,
              t.tlSentBody(
                formatTime(sent ?? payout.requestedAt),
                payout.providerReference ?? 'IYO-$ref_',
              ),
              payout.status == PayoutStatus.pending ? null : payout.requestedAt,
            ),
            step(
              sent != null ? t.tlDelivered : t.tlWaiting,
              sent != null ? t.tlDeliveredBody(formatTime(sent)) : '',
              sent,
              last: true,
            ),
          ],
        ),
        Footnote(t.payoutHelp(ref_)),
      ],
    );
  }

  Future<void> _shareStatement(
    BuildContext context,
    Payout p,
    String reference,
    PayoutBreakdown b,
    String account,
  ) {
    final t = context.t;
    final text = [
      t.statementTitle(reference),
      t.payoutSubtitle(
        reference,
        formatPeriodRange(context, p.periodStart ?? p.requestedAt, p.periodEnd ?? p.requestedAt),
      ),
      '${t.rideFaresLine(tripsLabel(context, b.trips))}: ${formatFcfa(b.fares)}',
      if (b.rentalHandovers > 0) '${t.rentalHandoverEarnings}: ${formatFcfa(b.rentalHandovers)}',
      '${t.tipsLine}: ${formatFcfa(b.tips)}',
      '${t.serviceFeesLine}: −${formatFcfa(b.serviceFees)}',
      '${t.netPayout}: ${formatFcfa(b.net)}',
      account,
    ].join('\n');
    return SharePlus.instance.share(ShareParams(text: text, subject: t.statementTitle(reference)));
  }
}
