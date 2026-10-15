import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iyo_core/iyo_core.dart';
import 'package:iyo_ui/iyo_ui.dart';

import '../sample/sample_data.dart';
import '../widgets/driver_widgets.dart';

final _plate = RegExp(r'^[A-Z]{2} ?[0-9]{3,4} ?[A-Z]{1,2}$');

//// DRIVER SETUP · 01 — Identity and vehicle (Figma 2005:51073). The frame's five fields come
/// first; city and national ID (needed by the review) follow under "Also needed".
class IdentityVehicleScreen extends ConsumerStatefulWidget {
  const IdentityVehicleScreen({super.key, this.preview = false});

  final bool preview;

  @override
  ConsumerState<IdentityVehicleScreen> createState() => _IdentityVehicleScreenState();
}

class _IdentityVehicleScreenState extends ConsumerState<IdentityVehicleScreen> {
  String? _city = 'douala';
  String _category = 'standard';
  final _name = TextEditingController();
  final _licence = TextEditingController();
  final _nid = TextEditingController();
  final _plateCtrl = TextEditingController();
  DateTime? _dob;
  String _make = '', _model = '', _color = '';
  int? _year;
  final Map<String, String?> _errors = {};
  bool _saving = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    if (widget.preview) {
      _name.text = DriverSample.driverName;
      _licence.text = 'LT-DL-552210';
      _plateCtrl.text = DriverSample.vehiclePlate;
      _dob = DateTime(1991, 5, 14);
      _make = DriverSample.vehicleMake;
      _model = DriverSample.vehicleModel;
      _color = DriverSample.vehicleColor;
      _year = DriverSample.vehicleYear;
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _licence, _nid, _plateCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _prefill(DriverAccount a, UserProfile? p) {
    if (_prefilled || widget.preview) return;
    _prefilled = true;
    _name.text = p?.fullName ?? '';
    _city = a.cityCode ?? _city;
    _licence.text = a.licenceNumber ?? '';
    _nid.text = a.nationalIdNumber ?? '';
    _dob = a.dateOfBirth;
    final v = a.vehicle;
    if (v != null) {
      _make = v.make;
      _model = v.model;
      _year = v.year;
      _color = v.color;
      _plateCtrl.text = v.plate;
      _category = v.categoryCode;
    }
  }

  String get _vehicleText =>
      _make.isEmpty
          ? ''
          : [
            '$_make $_model'.trim(),
            if (_year != null) '$_year',
            if (_color.isNotEmpty) _color,
          ].join(' · ');

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 30),
      firstDate: DateTime(now.year - 80),
      lastDate: DateTime(now.year - 21, now.month, now.day),
      initialEntryMode: DatePickerEntryMode.input,
    );
    if (d != null) setState(() => _dob = d);
  }

  Future<void> _editVehicle() async {
    final r = await showModalBottomSheet<_VehicleDraft>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: IyoPalette.white,
      barrierColor: IyoPalette.overlay,
      builder: (_) => _VehicleSheet(draft: _VehicleDraft(_make, _model, _year, _color, _category)),
    );
    if (r != null) {
      setState(() {
        _make = r.make;
        _model = r.model;
        _year = r.year;
        _color = r.color;
        _category = r.category;
      });
    }
  }

  Future<void> _save() async {
    if (widget.preview) return;
    final t = context.t;
    final required = CommonLocalizations.of(context).validationRequired;
    final plate = _plateCtrl.text.trim().toUpperCase();
    setState(() {
      _errors
        ..clear()
        ..['name'] = _name.text.trim().isEmpty ? required : null
        ..['dob'] = _dob == null ? t.dobInvalid : null
        ..['licence'] = _licence.text.trim().isEmpty ? required : null
        ..['nid'] = _nid.text.trim().isEmpty ? required : null
        ..['vehicle'] =
            _make.isEmpty || _model.isEmpty || _color.isEmpty || _year == null ? required : null
        ..['plate'] = _plate.hasMatch(plate) ? null : t.plateInvalid;
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
            legalName: _name.text.trim(),
            dateOfBirth: _dob,
            vehicle: VehicleInfo(
              make: _make,
              model: _model,
              color: _color,
              plate: plate,
              categoryCode: _category,
              year: _year,
              seats: _category == 'xl' ? 6 : 4,
            ),
          );
      if (mounted) context.go('/onboarding/documents');
    } on BackendException catch (e) {
      if (mounted) {
        setState(
          () =>
              _errors['form'] =
                  e.code == 'driver_identity_locked' ? t.identityLocked : t.errorGeneric,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (!widget.preview) {
      final account = ref.watch(driverAccountProvider).value;
      if (account != null) _prefill(account, ref.watch(profileProvider).value);
    }
    return IyoScreen(
      header: DriverHeader(flowLabel: t.flowSetup('01')),
      heading: IyoPageHeading(title: t.setupTitle, subtitle: t.setupStep1),
      footer: [
        if (_errors['form'] != null) Footnote(_errors['form']!, color: IyoPalette.danger),
        IyoButton(label: t.saveAndContinue, loading: _saving, onPressed: _save),
      ],
      children: [
        Align(alignment: Alignment.centerLeft, child: IyoBadge(t.driverAccountBadge)),
        IyoTextField(
          label: t.legalName,
          controller: _name,
          error: _errors['name'],
          autofillHints: const [AutofillHints.name],
          textInputAction: TextInputAction.next,
        ),
        IyoTextField(
          key: ValueKey('dob$_dob'),
          label: t.dateOfBirth,
          initialValue: _dob == null ? null : formatLongDate(context, _dob!),
          placeholder: t.dateOfBirthHint,
          readOnly: true,
          onTap: widget.preview ? null : _pickDob,
          error: _errors['dob'],
        ),
        IyoTextField(
          label: t.fieldLicence,
          controller: _licence,
          error: _errors['licence'],
          textInputAction: TextInputAction.next,
        ),
        IyoTextField(
          key: ValueKey('vehicle$_vehicleText'),
          label: t.vehicleMakeModel,
          initialValue: _vehicleText.isEmpty ? null : _vehicleText,
          placeholder: t.vehicleMakeModelHint,
          readOnly: true,
          onTap: widget.preview ? null : _editVehicle,
          error: _errors['vehicle'],
        ),
        IyoTextField(
          label: t.vehicleRegistration,
          controller: _plateCtrl,
          placeholder: 'LT 123 AB',
          helper: t.vehicleCheckedHelper,
          highlighted: widget.preview,
          error: _errors['plate'],
        ),
        if (!widget.preview) ...[
          SectionTitle(t.moreDetails),
          IyoSelectField<String>(
            label: t.fieldCity,
            value: _city,
            onChanged: (v) => setState(() => _city = v),
            options: const [
              IyoSelectOption(value: 'douala', label: 'Douala'),
              IyoSelectOption(value: 'yaounde', label: 'Yaoundé'),
            ],
          ),
          IyoTextField(label: t.fieldNationalId, controller: _nid, error: _errors['nid']),
        ],
        Footnote(t.legalDetailsNote),
      ],
    );
  }
}

class _VehicleDraft {
  const _VehicleDraft(this.make, this.model, this.year, this.color, this.category);

  final String make, model;
  final int? year;
  final String color, category;
}

/// Make, model, year, colour and category behind the single "Vehicle make & model" field.
class _VehicleSheet extends StatefulWidget {
  const _VehicleSheet({required this.draft});

  final _VehicleDraft draft;

  @override
  State<_VehicleSheet> createState() => _VehicleSheetState();
}

class _VehicleSheetState extends State<_VehicleSheet> {
  late final _make = TextEditingController(text: widget.draft.make);
  late final _model = TextEditingController(text: widget.draft.model);
  late final _year = TextEditingController(text: widget.draft.year?.toString() ?? '');
  late final _color = TextEditingController(text: widget.draft.color);
  late String _category = widget.draft.category;
  String? _yearError;

  @override
  void dispose() {
    for (final c in [_make, _model, _year, _color]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              IyoText(t.vehicleSheetTitle, variant: IyoTextVariant.cardTitle),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: IyoTextField(
                      label: t.fieldMake,
                      controller: _make,
                      placeholder: 'Toyota',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: IyoTextField(
                      label: t.fieldModel,
                      controller: _model,
                      placeholder: 'Corolla',
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: IyoTextField(
                      label: t.fieldYear,
                      controller: _year,
                      placeholder: '2018',
                      keyboardType: TextInputType.number,
                      error: _yearError,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: IyoTextField(
                      label: t.fieldColor,
                      controller: _color,
                      placeholder: 'Blanc',
                    ),
                  ),
                ],
              ),
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
              IyoButton(
                label: CommonLocalizations.of(context).actionSave,
                onPressed: () {
                  final year = int.tryParse(_year.text.trim());
                  if (year == null || year < 1990 || year > DateTime.now().year + 1) {
                    setState(() => _yearError = t.yearInvalid);
                    return;
                  }
                  Navigator.pop(
                    context,
                    _VehicleDraft(
                      _make.text.trim(),
                      _model.text.trim(),
                      year,
                      _color.text.trim(),
                      _category,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
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

//// The four groups of the Figma checklist, each made of the documents the review needs.
enum DocGroup {
  identity([DocumentType.nationalIdFront, DocumentType.nationalIdBack, DocumentType.profilePhoto]),
  licence([DocumentType.drivingLicence]),
  vehicle([DocumentType.vehicleRegistration, DocumentType.roadworthiness]),
  insurance([DocumentType.insurance]);

  const DocGroup(this.types);

  final List<DocumentType> types;
}

/// DRIVER SETUP · 02 — Documents and upload state (Figma 2005:51117).
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key, this.preview = false});

  final bool preview;

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final Map<DocumentType, double> _uploading = {};
  final Map<DocumentType, String> _fileNames = {};
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
    setState(() {
      _uploading[type] = 0;
      _fileNames[type] = path.split(RegExp(r'[\\/]')).last;
      _error = null;
    });
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

  String _groupTitle(DocGroup g) {
    final t = context.t;
    return switch (g) {
      DocGroup.identity => t.groupIdentity,
      DocGroup.licence => t.groupLicence,
      DocGroup.vehicle => t.groupVehicle,
      DocGroup.insurance => t.groupInsurance,
    };
  }

  String _groupDone(DocGroup g) {
    final t = context.t;
    return switch (g) {
      DocGroup.identity => t.groupIdentityDone,
      DocGroup.licence => t.groupLicenceDone,
      DocGroup.vehicle => t.groupVehicleDone,
      DocGroup.insurance => t.groupInsuranceDone,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final preview = widget.preview;
    final docs =
        preview
            ? {
              for (final d in DocumentType.values)
                if (d != DocumentType.insurance)
                  d: DriverDocument(type: d, status: ReviewStatus.pending),
              DocumentType.insurance: const DriverDocument(
                type: DocumentType.insurance,
                status: ReviewStatus.rejected,
                rejectionReason: 'The expiry date is blurry. Upload a clearer photo.',
              ),
            }
            : ref.watch(driverAccountProvider).value?.documents ??
                const <DocumentType, DriverDocument>{};

    bool ok(DocumentType d) => docs[d] != null && docs[d]!.status != ReviewStatus.rejected;
    final ready = [
      for (final g in DocGroup.values)
        if (g.types.every(ok)) g,
    ];
    final complete = ready.length == DocGroup.values.length;
    // The document to do next: rejected first, then missing, in checklist order.
    DocumentType? next;
    for (final g in DocGroup.values) {
      for (final d in g.types) {
        if (next == null && docs[d]?.status == ReviewStatus.rejected) next = d;
      }
    }
    for (final g in DocGroup.values) {
      for (final d in g.types) {
        if (next == null && docs[d] == null) next = d;
      }
    }
    final rejected = next != null && docs[next]?.status == ReviewStatus.rejected;
    final uploading = next != null && _uploading.containsKey(next);
    final nextTitle = next == null ? '' : documentTitle(context, next);

    return IyoScreen(
      header: DriverHeader(flowLabel: t.flowSetup('02')),
      heading: IyoPageHeading(title: t.docsTitle, subtitle: t.setupStep2),
      footer: [
        if (_error != null) Footnote(_error!, color: IyoPalette.danger),
        if (complete)
          IyoButton(
            label: t.submitForReview,
            disabled: _uploading.isNotEmpty,
            loading: _submitting,
            onPressed: preview ? () {} : _submit,
          )
        else
          IyoButton(
            label:
                rejected
                    ? t.retakeDoc(nextTitle.toLowerCase())
                    : t.uploadDoc(nextTitle.toLowerCase()),
            loading: uploading,
            onPressed: preview || uploading ? null : () => _choose(next!),
          ),
      ],
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IyoBadge(t.docsReady('${ready.length}', '${DocGroup.values.length}')),
        ),
        IyoCard(
          children: [
            // The group being worked on shows as the field below, not in the checklist.
            for (final g in DocGroup.values.where((g) => next == null || !g.types.contains(next)))
              if (g.types.every(ok))
                IyoListRow(
                  icon: LucideIcons.circleCheck,
                  title: _groupTitle(g),
                  subtitle:
                      g.types.every((d) => docs[d]!.status == ReviewStatus.approved)
                          ? t.groupApproved
                          : _groupDone(g),
                  trailing: const IyoText('✓', variant: IyoTextVariant.bodyStrong),
                  showChevron: false,
                )
              else
                IyoListRow(
                  icon: LucideIcons.circleDashed,
                  title: _groupTitle(g),
                  subtitle: t.groupMissing('${g.types.where((d) => !ok(d)).length}'),
                  showChevron: false,
                  onPressed: preview ? null : () => _choose(g.types.firstWhere((d) => !ok(d))),
                ),
          ],
        ),
        if (next != null)
          IyoFormField(
            label: documentTitle(context, next),
            error: rejected ? docs[next]!.rejectionReason : null,
            helper: rejected ? null : t.nextDocument(documentTitle(context, next)),
            child: IyoPressable(
              onPressed: preview || uploading ? null : () => _choose(next!),
              child: Container(
                constraints: const BoxConstraints(minHeight: IyoSizes.inputMinHeight),
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
                decoration: BoxDecoration(
                  color: IyoPalette.white,
                  borderRadius: BorderRadius.circular(IyoRadii.md),
                  border: Border.all(
                    color: rejected ? IyoPalette.danger : IyoPalette.border,
                    width: rejected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IyoText(
                      preview
                          ? 'insurance_photo.jpg'
                          : _fileNames[next] ?? (rejected ? '${next.value}.jpg' : t.noFileYet),
                      variant: IyoTextVariant.input,
                      color:
                          preview || _fileNames[next] != null || rejected
                              ? IyoPalette.ink
                              : IyoPalette.muted,
                    ),
                    if (uploading) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _uploading[next],
                        minHeight: 3,
                        color: context.iyo.accent,
                        backgroundColor: IyoPalette.border,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        IyoCard(
          children: [
            IyoText(t.uploadTips, variant: IyoTextVariant.subheading),
            IyoText(
              t.uploadTipsBody,
              variant: IyoTextVariant.caption,
              color: IyoPalette.textSecondary,
            ),
          ],
        ),
        Footnote(t.reviewTimeNote),
      ],
    );
  }
}

// D7 — Verification status: under review / action needed / approved (Figma 2005:51170).
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
