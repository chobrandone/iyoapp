// Driver earnings and payouts (Figma "Driver · Earnings and payout history", "Payout details").
// Totals are computed from the driver's completed rides, which the server priced.
import 'package:flutter/foundation.dart';

import '../supabase/db_enums.dart';
import 'models.dart';

enum EarningsPeriod { week, month, year }

/// Earnings for the current week (Mon–Sun), month (weeks) or year (months) so far.
@immutable
class EarningsSummary {
  const EarningsSummary({
    required this.period,
    required this.start,
    required this.end,
    required this.total,
    required this.trips,
    required this.driveSeconds,
    required this.buckets,
    required this.currentBucket,
    this.changePercent,
  });

  final EarningsPeriod period;
  final DateTime start;

  /// Exclusive.
  final DateTime end;
  final int total;
  final int trips;

  /// Time spent on trips (pickup to drop-off).
  final int driveSeconds;

  /// Week: 7 days; month: up to 5 weeks; year: 12 months.
  final List<int> buckets;

  /// Index of today's bucket (highlighted in the chart).
  final int currentBucket;

  /// Against the same stretch of the previous period; null when there is nothing to compare.
  final double? changePercent;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static (DateTime, DateTime) range(EarningsPeriod p, DateTime now) {
    final today = _day(now);
    return switch (p) {
      EarningsPeriod.week => (
        today.subtract(Duration(days: today.weekday - 1)),
        today.subtract(Duration(days: today.weekday - 1)).add(const Duration(days: 7)),
      ),
      EarningsPeriod.month => (DateTime(now.year, now.month), DateTime(now.year, now.month + 1)),
      EarningsPeriod.year => (DateTime(now.year), DateTime(now.year + 1)),
    };
  }

  /// [trips] must cover at least the previous period too (for the change percentage).
  factory EarningsSummary.from(List<CompletedTrip> trips, EarningsPeriod p, DateTime now) {
    final (start, end) = range(p, now);
    int bucketOf(DateTime d) => switch (p) {
      EarningsPeriod.week => _day(d).difference(start).inDays,
      EarningsPeriod.month => (d.day - 1) ~/ 7,
      EarningsPeriod.year => d.month - 1,
    };
    final count = switch (p) {
      EarningsPeriod.week => 7,
      EarningsPeriod.month => ((DateTime(now.year, now.month + 1, 0).day - 1) ~/ 7) + 1,
      EarningsPeriod.year => 12,
    };
    final buckets = List.filled(count, 0);
    var total = 0, n = 0, seconds = 0;
    for (final t in trips) {
      final d = t.completedAt.toLocal();
      if (d.isBefore(start) || !d.isBefore(end)) continue;
      buckets[bucketOf(d)] += t.earnings;
      total += t.earnings;
      n++;
      seconds += t.durationSeconds;
    }
    // Same elapsed stretch of the previous period.
    final (prevStart, _) = switch (p) {
      EarningsPeriod.week => (start.subtract(const Duration(days: 7)), start),
      EarningsPeriod.month => (DateTime(start.year, start.month - 1), start),
      EarningsPeriod.year => (DateTime(start.year - 1), start),
    };
    final prevEnd = prevStart.add(now.difference(start));
    final previous = trips
        .where(
          (t) =>
              !t.completedAt.toLocal().isBefore(prevStart) &&
              t.completedAt.toLocal().isBefore(prevEnd),
        )
        .fold(0, (s, t) => s + t.earnings);
    return EarningsSummary(
      period: p,
      start: start,
      end: end,
      total: total,
      trips: n,
      driveSeconds: seconds,
      buckets: buckets,
      currentBucket: bucketOf(now),
      changePercent: previous == 0 ? null : (total - previous) * 100 / previous,
    );
  }
}

@immutable
class Payout {
  const Payout({
    required this.id,
    required this.amount,
    required this.method,
    required this.phone,
    required this.status,
    required this.requestedAt,
    this.periodStart,
    this.periodEnd,
    this.paidAt,
    this.providerReference,
    this.failureReason,
  });

  final String id;
  final int amount;
  final PaymentMethodType method;
  final String phone;
  final PayoutStatus status;
  final DateTime requestedAt;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime? paidAt;
  final String? providerReference;
  final String? failureReason;

  /// PO-071 style reference shown to drivers and support.
  String get reference {
    if (RegExp(r'^PO-\d+$').hasMatch(id)) return id;
    var h = 0;
    for (final c in id.codeUnits) {
      h = (h * 31 + c) % 1000;
    }
    return 'PO-${h.toString().padLeft(3, '0')}';
  }
}

/// What a payout is made of: the rides in its period.
@immutable
class PayoutBreakdown {
  const PayoutBreakdown({
    required this.trips,
    required this.fares,
    required this.tips,
    required this.serviceFees,
    this.rentalHandovers = 0,
  });

  factory PayoutBreakdown.of(List<CompletedTrip> trips) {
    final fares = trips.fold(0, (s, t) => s + t.fareAmount);
    final tips = trips.fold(0, (s, t) => s + t.tip);
    final earnings = trips.fold(0, (s, t) => s + t.earnings);
    return PayoutBreakdown(
      trips: trips.length,
      fares: fares,
      tips: tips,
      serviceFees: fares + tips - earnings,
    );
  }

  final int trips;
  final int fares;
  final int tips;
  final int serviceFees;
  final int rentalHandovers;

  int get net => fares + tips + rentalHandovers - serviceFees;
}
