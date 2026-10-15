import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../widgets/driver_widgets.dart';

final _plate = RegExp(r'^[A-Z]{2} ?[0-9]{3,4} ?[A-Z]{1,2}$');

/// D5 — Identity and vehicle setup (Figma 2005:51073; frame not attached).
class IdentityVehicleScreen extends ConsumerStatefulWidget {
  const IdentityVehicleScreen({super.key});

  @override
  ConsumerState<IdentityVehicleScreen> createState() => _IdentityVehicleScreenState();
}

class _IdentityVehicleScreenState extends ConsumerState<IdentityVehicleScreen> {
  String? _city = 'douala';
  String _category = 'standard';
  final _licence = TextEditingController();
  final _nid = TextEditingController();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _color = TextEditingController();
  final _plateCtrl = TextEditingController();
  final Map<String, String?> _errors = {};
  bool _saving = false;
  bool _prefilled = false;

  @override
  void dispose() {
    for (final c in [_licence, _nid, _make, _model, _year, _color, _plateCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _prefill(DriverAccount a) {
    if (_prefilled) return;
    _prefilled = true;
    _city = a.cityCode ?? _city;
    _licence.text = a.licenceNumber ?? '';
    _nid.text = a.nationalIdNumber ?? '';
    final v = a.vehicle;
    if (v != null) {
      _make.text = v.make;
      _model.text = v.model;
      _year.text = v.year?.toString() ?? '';
      _color.text = v.color;
      _plateCtrl.text = v.plate;
      _category = v.categoryCode;
    }
  }

  Future<void> _save() async {
    final t = context.t;
    final required = CommonLocalizations.of(context).validationRequired;
    final plate = _plateCtrl.text.trim().toUpperCase();
    final year = int.tryParse(_year.text.trim());
    setState(() {
      _errors
        ..clear()
        ..['licence'] = _licence.text.trim().isEmpty ? required : null
        ..['nid'] = _nid.text.trim().isEmpty ? required : null
        ..['make'] = _make.text.trim().isEmpty ? required : null
        ..['model'] = _model.text.trim().isEmpty ? required : null
        ..['color'] = _color.text.trim().isEmpty ? required : null
        ..['plate'] = _plate.hasMatch(plate) ? null : t.plateInvalid
        ..['year'] =
            year == null || year < 1990 || year > DateTime.now().year + 1 ? t.yearInvalid : null;
    });
    if (_errors.values.any((e) => e != null)) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(backendProvider)
          .saveIdentity(
            cityCode: _city!,
            licenceNumber: _licence.text.trim(),
            nationalIdNumber: _nid.text.trim(),
            vehicle: VehicleInfo(
              make: _make.text.trim(),
              model: _model.text.trim(),
              color: _color.text.trim(),
              plate: plate,
              categoryCode: _category,
              year: year,
              seats: _category == 'xl' ? 6 : 4,
            ),
          );
      if (mounted) context.go('/onboarding/documents');
    } on BackendException {
      if (mounted) setState(() => _errors['form'] = t.errorGeneric);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final account = ref.watch(driverAccountProvider).value;
    if (account != null) _prefill(account);
    const gap = SizedBox(height: 14);
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flow('05')),
      heading: IyoPageHeading(title: t.identityTitle, subtitle: t.identitySubtitle),
      footer: [
        if (_errors['form'] != null) Footnote(_errors['form']!, color: IyoPalette.danger),
        IyoButton(label: t.continueToDocuments, loading: _saving, onPressed: _save),
      ],
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(alignment: Alignment.centerLeft, child: IyoBadge(t.stepOf('1', '2'))),
            gap,
            IyoSelectField<String>(
              label: t.fieldCity,
              value: _city,
              onChanged: (v) => setState(() => _city = v),
              options: const [
                IyoSelectOption(value: 'douala', label: 'Douala'),
                IyoSelectOption(value: 'yaounde', label: 'Yaoundé'),
              ],
            ),
            gap,
            IyoTextField(label: t.fieldLicence, controller: _licence, error: _errors['licence']),
            gap,
            IyoTextField(label: t.fieldNationalId, controller: _nid, error: _errors['nid']),
            const SizedBox(height: 22),
            SectionTitle(t.vehicleSection),
            gap,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: IyoTextField(
                    label: t.fieldMake,
                    controller: _make,
                    placeholder: 'Toyota',
                    error: _errors['make'],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: IyoTextField(
                    label: t.fieldModel,
                    controller: _model,
                    placeholder: 'Corolla',
                    error: _errors['model'],
                  ),
                ),
              ],
            ),
            gap,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: IyoTextField(
                    label: t.fieldYear,
                    controller: _year,
                    placeholder: '2018',
                    keyboardType: TextInputType.number,
                    error: _errors['year'],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: IyoTextField(
                    label: t.fieldColor,
                    controller: _color,
                    placeholder: 'Blanc',
                    error: _errors['color'],
                  ),
                ),
              ],
            ),
            gap,
            IyoTextField(
              label: t.fieldPlate,
              controller: _plateCtrl,
              placeholder: 'LT 123 AB',
              helper: t.plateHelper,
              error: _errors['plate'],
            ),
            gap,
            IyoSelectField<String>(
              label: t.fieldCategory,
              value: _category,
              onChanged: (v) => setState(() => _category = v),
              options: [
                IyoSelectOption(value: 'standard', label: t.categoryStandard),
                IyoSelectOption(value: 'comfort', label: t.categoryComfort),
                IyoSelectOption(value: 'xl', label: t.categoryXl),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

String documentTitle(BuildContext context, DocumentType type) {
  final t = context.t;
  return switch (type) {
    DocumentType.nationalIdFront => t.docNationalIdFront,
    DocumentType.nationalIdBack => t.docNationalIdBack,
    DocumentType.drivingLicence => t.docDrivingLicence,
    DocumentType.vehicleRegistration => t.docVehicleRegistration,
    DocumentType.insurance => t.docInsurance,
    DocumentType.roadworthiness => t.docRoadworthiness,
    DocumentType.profilePhoto => t.docProfilePhoto,
  };
}

/// Picks a document photo; overridden in tests.
final documentPickerProvider = Provider<Future<String?> Function(ImageSource)>(
  (ref) =>
      (source) async =>
          (await ImagePicker().pickImage(source: source, imageQuality: 80, maxWidth: 2000))?.path,
);

/// D6 — Documents and upload state (Figma 2005:51117; frame not attached).
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final Map<DocumentType, double> _uploading = {};
  bool _submitting = false;
  String? _error;

  Future<void> _choose(DocumentType type) async {
    final t = context.t;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      backgroundColor: IyoPalette.white,
      builder:
          (sheet) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IyoText(documentTitle(context, type), variant: IyoTextVariant.cardTitle),
                  const SizedBox(height: 12),
                  IyoButton(
                    label: t.takePhoto,
                    icon: LucideIcons.camera,
                    onPressed: () => Navigator.of(sheet).pop(ImageSource.camera),
                  ),
                  const SizedBox(height: 10),
                  IyoButton(
                    label: t.chooseFromGallery,
                    icon: LucideIcons.image,
                    variant: IyoButtonVariant.secondary,
                    onPressed: () => Navigator.of(sheet).pop(ImageSource.gallery),
                  ),
                ],
              ),
            ),
          ),
    );
    if (source == null) return;
    final path = await ref.read(documentPickerProvider)(source);
    if (path == null) return;
    setState(() => _uploading[type] = 0);
    try {
      await ref
          .read(backendProvider)
          .uploadDocument(
            type,
            path,
            onProgress: (p) {
              if (mounted) setState(() => _uploading[type] = p);
            },
          );
    } on BackendException {
      if (mounted) setState(() => _error = t.errorGeneric);
    } finally {
      if (mounted) setState(() => _uploading.remove(type));
    }
  }

  Future<void> _submit() async {
    final t = context.t;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(backendProvider).submitApplication();
      if (mounted) context.go('/onboarding/status');
    } on BackendException catch (e) {
      if (mounted) {
        setState(
          () => _error = e.code == 'documents_missing' ? t.documentsMissingError : t.errorGeneric,
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final account = ref.watch(driverAccountProvider).value;
    final docs = account?.documents ?? const <DocumentType, DriverDocument>{};
    final complete = DocumentType.values.every(
      (d) => docs.containsKey(d) && docs[d]!.status != ReviewStatus.rejected,
    );
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flow('06')),
      heading: IyoPageHeading(
        title: t.documentsTitle,
        subtitle: t.documentsSubtitle,
        onBack: () => context.go('/onboarding/identity'),
      ),
      footer: [
        if (_error != null) Footnote(_error!, color: IyoPalette.danger),
        IyoButton(
          label: t.submitForReview,
          disabled: !complete || _uploading.isNotEmpty,
          loading: _submitting,
          onPressed: _submit,
        ),
      ],
      children: [
        Align(alignment: Alignment.centerLeft, child: IyoBadge(t.stepOf('2', '2'))),
        IyoCard(
          children: [
            for (final type in DocumentType.values)
              DocumentUploadRow(
                key: ValueKey(type),
                title: documentTitle(context, type),
                progress: _uploading[type] ?? 0,
                rejectionReason: docs[type]?.rejectionReason,
                state:
                    _uploading.containsKey(type)
                        ? UploadState.uploading
                        : switch (docs[type]?.status) {
                          null => UploadState.missing,
                          ReviewStatus.pending => UploadState.pending,
                          ReviewStatus.approved => UploadState.approved,
                          ReviewStatus.rejected => UploadState.rejected,
                        },
                onTap: () => _choose(type),
              ),
          ],
        ),
      ],
    );
  }
}

/// D7 — Verification status: under review / action needed / approved (Figma 2005:51170).
class VerificationStatusScreen extends ConsumerWidget {
  const VerificationStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final account = ref.watch(driverAccountProvider).value;
    final status = account?.status ?? VerificationStatus.underReview;
    final demo = ref.watch(backendProvider).isDemo;
    final (title, subtitle, icon, tone) = switch (status) {
      VerificationStatus.approved => (
        t.approvedTitle,
        t.approvedSubtitle,
        LucideIcons.badgeCheck,
        IyoBadgeTone.success,
      ),
      VerificationStatus.actionNeeded || VerificationStatus.rejected => (
        t.actionNeededTitle,
        account?.reviewNotes ?? t.actionNeededSubtitle,
        LucideIcons.circleAlert,
        IyoBadgeTone.danger,
      ),
      _ => (t.reviewTitle, t.reviewSubtitle, LucideIcons.clock3, IyoBadgeTone.accent),
    };
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flow('07')),
      heading: IyoPageHeading(title: title, subtitle: subtitle),
      footer: [
        if (status == VerificationStatus.approved)
          IyoButton(label: t.startDriving, onPressed: () => context.go('/home'))
        else if (status == VerificationStatus.actionNeeded || status == VerificationStatus.rejected)
          IyoButton(label: t.fixDocuments, onPressed: () => context.go('/onboarding/documents')),
      ],
      children: [
        IyoCard(
          tone: switch (tone) {
            IyoBadgeTone.success => IyoCardTone.success,
            IyoBadgeTone.danger => IyoCardTone.danger,
            _ => IyoCardTone.accent,
          },
          children: [
            Align(alignment: Alignment.centerLeft, child: IyoIcon(icon, size: 28)),
            IyoText(title, variant: IyoTextVariant.cardTitle),
            if (account?.vehicle != null)
              IyoText(
                '${account!.vehicle!.label} · ${account.vehicle!.plate}',
                color: IyoPalette.charcoal,
              ),
          ],
        ),
        if (account != null)
          IyoCard(
            children: [
              for (final type in DocumentType.values)
                if (account.documents[type] case final doc?)
                  DocumentUploadRow(
                    title: documentTitle(context, type),
                    rejectionReason: doc.rejectionReason,
                    state: switch (doc.status) {
                      ReviewStatus.pending => UploadState.pending,
                      ReviewStatus.approved => UploadState.approved,
                      ReviewStatus.rejected => UploadState.rejected,
                    },
                  ),
            ],
          ),
        if (demo && status == VerificationStatus.underReview) Footnote(t.reviewDemo),
      ],
    );
  }
}
