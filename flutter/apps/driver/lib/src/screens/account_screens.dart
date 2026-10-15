import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../locale_controller.dart';
import '../sample/sample_data.dart';
import '../state/online.dart';
import '../widgets/driver_widgets.dart';
import 'bookings_screens.dart';
import 'earnings_screens.dart';
import 'home_screens.dart';
import 'onboarding_screens.dart';

/// DR-### reference shown to drivers and support, from the user id.
String driverRef(String userId) {
  var h = 0;
  for (final c in userId.codeUnits) {
    h = (h * 31 + c) % 1000;
  }
  return 'DR-${h.toString().padLeft(3, '0')}';
}

/// The documents the account frame lists, in its order (licence, vehicle papers, insurance).
const _accountDocs = [
  DocumentType.drivingLicence,
  DocumentType.vehicleRegistration,
  DocumentType.insurance,
];

/// DRIVER — Account and vehicle management (Figma 2025:643).
class DriverAccountScreen extends ConsumerWidget {
  const DriverAccountScreen({super.key, this.preview = false});

  final bool preview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final profile = preview ? null : ref.watch(profileProvider).value;
    final account = preview ? null : ref.watch(driverAccountProvider).value;
    final trips = preview ? null : ref.watch(recentTripsProvider).value;
    final isFrench = Localizations.localeOf(context).languageCode == 'fr';
    final common = CommonLocalizations.of(context);

    final name = preview ? DriverSample.driverName : profile?.fullName ?? '';
    final rating = preview ? DriverSample.driverRating : profile?.rating?.toStringAsFixed(1) ?? '–';
    final tripCount =
        preview ? DriverSample.driverTrips : profile?.ratingCount ?? trips?.length ?? 0;
    final ref_ = preview ? DriverSample.driverRef : driverRef(profile?.id ?? '');
    final approved = preview || account?.status == VerificationStatus.approved;
    final vehicle = account?.vehicle;
    final category = categoryLabel(
      context,
      preview ? 'standard' : vehicle?.categoryCode ?? 'standard',
    );

    String docLine(DocumentType type) {
      if (preview) {
        return switch (type) {
          DocumentType.drivingLicence => t.docVerifiedExpires('22 May 2029'),
          DocumentType.vehicleRegistration => t.docVerifiedExpires('6 Apr 2027'),
          DocumentType.insurance => t.docRenewBy('30 Nov 2026'),
          _ => t.docVerifiedExpires('14 Mar 2027'),
        };
      }
      final d = account?.documents[type];
      if (d == null) return t.docNotUploaded;
      return switch (d.status) {
        ReviewStatus.approved
            when d.expiresOn != null && d.expiresOn!.difference(DateTime.now()).inDays < 60 =>
          t.docRenewBy(formatLongDate(context, d.expiresOn!)),
        ReviewStatus.approved when d.expiresOn != null => t.docVerifiedExpires(
          formatLongDate(context, d.expiresOn!),
        ),
        ReviewStatus.approved => t.docVerified,
        ReviewStatus.rejected => t.docNeedsAction(d.rejectionReason ?? ''),
        _ => t.docInReview,
      };
    }

    bool needsAttention(DocumentType type) {
      if (preview) return type == DocumentType.insurance;
      final d = account?.documents[type];
      if (d == null || d.status == ReviewStatus.rejected) return true;
      return d.expiresOn != null && d.expiresOn!.difference(DateTime.now()).inDays < 60;
    }

    final payTo =
        preview
            ? DriverSample.payoutAccount
            : account?.payoutMethod == null || account?.payoutPhone == null
            ? t.notSet
            : payoutAccount(context, account!.payoutMethod!, account.payoutPhone!);

    return IyoScreen(
      inTabs: true,
      header: DriverHeader(flowLabel: t.flowPlain),
      heading: IyoPageHeading(title: t.accountHeading, subtitle: t.accountSub, compact: true),
      footer: [
        IyoButton(
          label: t.editAccount,
          onPressed: preview ? () {} : () => context.push('/onboarding/identity?edit=1'),
        ),
      ],
      children: [
        IyoCard(
          children: [
            Row(
              children: [
                IyoAvatar(name: name, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IyoText(name, variant: IyoTextVariant.heading, maxLines: 1),
                      IyoText(
                        t.driverMeta(rating, tripsLabel(context, tripCount), ref_),
                        variant: IyoTextVariant.caption,
                        color: IyoPalette.textSecondary,
                        style: const TextStyle(height: 1.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (approved)
              Align(
                alignment: Alignment.centerLeft,
                child: IyoBadge(t.verifiedDriver, tone: IyoBadgeTone.success),
              ),
          ],
        ),
        IyoCard(
          children: [
            IyoText(t.yourVehicle, variant: IyoTextVariant.cardTitle),
            RentalCarRow(
              imageWidth: 92,
              imageHeight: 62,
              gap: 12,
              name:
                  preview
                      ? '${DriverSample.vehicleMake} ${DriverSample.vehicleModel}'
                      : vehicle == null
                      ? '–'
                      : '${vehicle.make} ${vehicle.model}',
              specs:
                  preview
                      ? t.vehicleSpecs(
                        DriverSample.vehicleColor,
                        '${DriverSample.vehicleYear}',
                        '4',
                      )
                      : vehicle == null
                      ? ''
                      : t.vehicleSpecs(vehicle.color, '${vehicle.year ?? '–'}', '${vehicle.seats}'),
              badge: category,
            ),
            RichRow(
              title: t.plateServices(preview ? DriverSample.vehiclePlate : vehicle?.plate ?? '–'),
              chevron: true,
              subtitle: approved ? t.categoryApproved(category) : t.categoryInReview(category),
              onPressed: preview ? null : () => context.push('/onboarding/identity?edit=1'),
            ),
          ],
        ),
        IyoCard(
          children: [
            IyoText(t.documentsHeading, variant: IyoTextVariant.cardTitle),
            for (final type in _accountDocs)
              RichRow(
                title: documentTitle(context, type),
                chevron: needsAttention(type),
                subtitle: docLine(type),
                onPressed:
                    preview || !needsAttention(type)
                        ? null
                        : () => context.push('/onboarding/documents?edit=1'),
              ),
          ],
        ),
        RichRow(
          title: t.payoutDetailsRow,
          chevron: true,
          subtitle: payTo,
          onPressed: preview ? null : () => context.go('/earnings'),
        ),
        Footnote(t.vehicleChangeNote),
        if (!preview) ...[
          SectionTitle(t.moreSection),
          IyoCard(
            children: [
              IyoListRow(
                icon: LucideIcons.languages,
                iconWellTone: IyoIconWellTone.white,
                title: t.language,
                subtitle: isFrench ? common.languageFr : common.languageEn,
                onPressed:
                    () => ref
                        .read(localeControllerProvider.notifier)
                        .set(Locale(isFrench ? 'en' : 'fr')),
              ),
              IyoListRow(
                icon: LucideIcons.triangleAlert,
                iconWellTone: IyoIconWellTone.white,
                title: t.menuReportIncident,
                onPressed: () => context.push('/incident'),
              ),
              IyoListRow(
                icon: LucideIcons.logOut,
                iconWellTone: IyoIconWellTone.white,
                title: t.signOut,
                destructive: true,
                onPressed: () async {
                  await ref.read(onlineControllerProvider.notifier).goOffline();
                  await ref.read(backendProvider).signOut();
                },
              ),
            ],
          ),
        ],
      ],
    );
  }
}
