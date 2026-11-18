import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:db_atom/index.dart';
import 'package:db_atom/src/features/PPM_MFT/models/ppm_mft_model.dart';
import 'package:db_atom/src/features/PPM_MFT/services/ppm_mft_services.dart';
import 'package:db_atom/src/features/PPM_MFT/PPM_MFT_details/cubits/ppm_mft_cubit.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class PpmMftView extends StatefulWidget {
  final PpmMftModel? model;
  final String title;
  final ExtraProperties? extraProperties;

  const PpmMftView({
    super.key,
    this.model,
    required this.title,
    this.extraProperties,
  });

  @override
  State<PpmMftView> createState() => _PpmMftViewState();
}

class _PpmMftViewState extends State<PpmMftView> {
  @override
  void initState() {
    super.initState();
    context.read<PpmMftCubit>().initializeValues();
  }

  void _goToList() {
    Navigator.pop(context);
    Navigator.popAndPushNamed(context, ppmMftListRoute);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return BlocConsumer<PpmMftCubit, PpmMftState>(
      listener: (context, state) {
        Utils().formError(state, context);
        Utils().errorAndLogout(state, context);

        if (state.status == FormStatus.success) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => CustomAlertDialog(
              title: PpmMftConfig.title,
              message: state.message ?? '',
              positiveBtnText: Constants.ok,
              onPositivePressed: () {
                Navigator.pop(context); // dialog
                _goToList();
              },
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: BaseAppBar().buildAppHeader(
            context: context,
            title: widget.title,
            showPopUp: false,
            showSaveButton: false,
            showSubmitButton: false,
            showDisLikeButton: false,
            showLikeButton: false,
            pdfAPIName: '',
            popAndReplace: _goToList,
            onTapSave: () {
              FocusScope.of(context).unfocus();
              context.read<PpmMftCubit>().submitForm(isSaveOnly: true);
            },
            onTapSubmit: () {
              FocusScope.of(context).unfocus();
              context.read<PpmMftCubit>().submitForm();
            },
          ),
          body: _body(state, height),
        );
      },
    );
  }

  Widget _body(PpmMftState state, double height) {
    final m = state.model;
    final gap = CommonWidgets.verticalSpacerWidget(height * 0.01);
    final tightGap = CommonWidgets.verticalSpacerWidget(height * 0.001);
    final isDraft = m.status == PpmMftStatus.draft;
    final isUnderProgress = m.status == PpmMftStatus.underProgress;
    // When there are no engineers, show one empty card so the two columns
    // still appear, without any "No engineers added" text.
    final engineers =
    m.engineers.isEmpty ? [PpmMftEngineer()] : m.engineers;

    Widget field(String label, String? value,
        {bool mandatory = false, String keySuffix = ''}) {
      final v = value ?? '';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonWidgets.textDisplay(
            label,
            Styles.textStyleWhite14,
            isMandatory: mandatory,
          ),
          tightGap,
          FlutterInputField(
            key: ValueKey('$label$keySuffix-$v'),
            textFormKey: 'ppmMft_${label.replaceAll(' ', '')}$keySuffix',
            hintText: '',
            initialValue: v,
            isEnable: false,
            isDisableColor: true,
            onChange: (String value) {},
            validateTextField: (String? user) {},
          ),
          gap,
        ],
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/bg2.png', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(color: Colors.black.withValues(alpha: 0.1)),
          ),
        ),
        SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!m.lock.isEmptyOrNull)
                  RecordLockedWidget(text: '${m.lock}'),

                CommonWidgets.verticalSpacerWidget(height * 0.01),
                Text(
                  Constants.generalinformation,
                  style: Styles.styleHeaderWhiteText16,
                ),
                CommonWidgets.verticalSpacerWidget(height * 0.01),

                /// Status
                field(Constants.status, _statusText(m.status), mandatory: true),
                CommonWidgets.verticalSpacerWidget(height * 0.01),

                /// Created By
                CommonWidgets.horizontalTextHandling(
                  Constants.createdby,
                  m.entrySecurityName ?? '',
                  isMandatory: true,
                ),
                CommonWidgets.verticalSpacerWidget(height * 0.01),

                /// Sl No.
                CommonWidgets.horizontalTextHandling(
                  Constants.slno,
                  m.slNo ?? '',
                  isMandatory: true,
                ),
                CommonWidgets.verticalSpacerWidget(height * 0.01),

                /// Date of creation
                field(
                  Constants.dateofcreation,
                  PpmMftModel.formatTs(m.inputDate),
                  //mandatory: true,
                ),
                CommonWidgets.verticalSpacerWidget(height * 0.01),

                /// Location
                _chipsField(Constants.location, m.locations, mandatory: true),

                CommonWidgets.verticalSpacerWidget(height * 0.01),

                /// System Vendor
                _chipsField('System Vendor Name', m.vendors),
                CommonWidgets.verticalSpacerWidget(height * 0.01),

                /// PPM  MFT tendative date
                field('Next PPM MFT tentative date',
                    PpmMftModel.formatTs(m.fromDate),
                    mandatory: true),

                /// PPM  MFT conducted on
                field('PPM MFT conducted on ', PpmMftModel.formatTs(m.toDate),
                    mandatory: true),

                field('Engineer mobile', m.eventName),
                CommonWidgets.verticalSpacerWidget(height * 0.01),
                field('Engineer Name', m.followUp),
                CommonWidgets.verticalSpacerWidget(height * 0.01),
                field('CR No.', m.emailAddress),
                CommonWidgets.verticalSpacerWidget(height * 0.01),

                //field('Observations', m.comments),
                if (isUnderProgress) ...[
                  field('Observations', m.comments),
                  CommonWidgets.verticalSpacerWidget(height * 0.01),
                ],

                CommonWidgets.verticalSpacerWidget(height * 0.01),
                field('Action Owner', m.mailTo),
                CommonWidgets.verticalSpacerWidget(height * 0.01),
                field('Trigger to Other Users', m.mailToOtherUsers),
                CommonWidgets.verticalSpacerWidget(height * 0.01),

                // ---------------- Engineers ----------------
                // Text('Name of Engineer Attended PPM/MFT',
                //     style: Styles.styleHeaderWhiteText16),
                // gap,
                // if (m.engineers.isEmpty)
                //   CommonWidgets.horizontalTextHandling('', 'No engineers added')
                // else
                //   for (final (i, e) in m.engineers.indexed)
                //     _card(
                //       Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           field('Engineer Name', e.engineerName,
                //               keySuffix: '$i'),
                //           field('Engineer Mobile No', e.engineerMobile,
                //               keySuffix: '$i'),
                //         ],
                //       ),
                //     ),
                if (!isDraft) ...[
                  Text('Name of Engineer Attended PPM/MFT',
                      style: Styles.styleHeaderWhiteText16),
                  gap,
                  for (final (i, e) in engineers.indexed)
                    _card(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          field('Engineer Name', e.engineerName,
                              keySuffix: '$i'),
                          field('Engineer Mobile No', e.engineerMobile,
                              keySuffix: '$i'),
                        ],
                      ),
                    ),
                ],

                // ---------------- Attachments ----------------
                if (m.attachments.isNotEmpty) ...[
                  gap,
                  Text('Attachments', style: Styles.styleHeaderWhiteText16),
                  gap,
                  _attachmentsTable(m.attachments),
                ],
                CommonWidgets.verticalSpacerWidget(height * 0.01),
                field('modified on', m.eventName),
                CommonWidgets.verticalSpacerWidget(height * 0.01),
                field('modified by', m.eventName),
                CommonWidgets.verticalSpacerWidget(height * 0.01),

                CommonWidgets.verticalSpacerWidget(height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [_cancelButton()],
                ),
                CommonWidgets.verticalSpacerWidget(height * 0.2),
              ],
            ),
          ),
        ),
        if (state.status == FormStatus.loading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: BaseLoader()),
            ),
          ),
      ],
    );
  }

  Widget _card(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.5), width: 0.7),
        ),
        child: child,
      );

  /// Read-only multi-select box, like the web (blue chips in a rounded box).
  Widget _chipsField(String label, List<Organisation> items,
      {bool mandatory = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonWidgets.textDisplay(label, Styles.textStyleWhite14,
            isMandatory: mandatory),
        CommonWidgets.verticalSpacerWidget(4),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.4), width: 0.7),
          ),
          child: items.isEmpty
              ? const SizedBox(height: 20)
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final o in items)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          //color: const Color(0xFF5285E4),
                          color: const Color(0xFF2E4157),

                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(o.name ?? '',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14)),
                      ),
                  ],
                ),
        ),
        CommonWidgets.verticalSpacerWidget(10),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Attachments
  // ---------------------------------------------------------------------------
  Widget _attachmentsTable(List<ImageContent> items) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.5), width: 0.7),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF5F76E8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Text('Attachment',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
                Text('View / Download',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          for (final a in items)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(a.title ?? '',
                        style: Styles.textStyleWhite14,
                        overflow: TextOverflow.ellipsis),
                  ),
                  IconButton(
                    tooltip: 'View',
                    icon: const Icon(Icons.visibility, color: Colors.white),
                    onPressed: () => _viewAttachment(a),
                  ),
                  IconButton(
                    tooltip: 'Download',
                    icon: const Icon(Icons.download, color: Colors.white),
                    onPressed: () => _downloadAttachment(a),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Returns the attachment with its bytes. Uses the content already on the
  /// model if present, otherwise fetches it by id.
  Future<(ImageContent, Uint8List)?> _load(ImageContent a) async {
    try {
      final data = a.imageContent ?? '';
      if (data.isEmpty) throw Exception('Empty attachment');
      return (a, base64Decode(data));
    } catch (e, st) {
      log('PpmMft attachment error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to load the attachment')),
        );
      }
      return null;
    }
  }

  Future<File> _writeFile(ImageContent a, Uint8List bytes,
      {required bool permanent}) async {
    final dir = permanent
        ? await getApplicationDocumentsDirectory()
        : await getTemporaryDirectory();
    final name = (a.title ?? 'attachment_${a.id}').replaceAll('/', '_');
    return File('${dir.path}/$name').writeAsBytes(bytes, flush: true);
  }

  Future<void> _viewAttachment(ImageContent a) async {
    final loaded = await _load(a);
    if (loaded == null || !mounted) return;
    final (full, bytes) = loaded;

    final isImage = (full.contentType ?? a.contentType ?? '')
        .toLowerCase()
        .startsWith('image/');

    if (isImage) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              InteractiveViewer(child: Image.memory(bytes)),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    // PDF / XLS / XLSX: hand off to the device's viewer.
    final file = await _writeFile(a, bytes, permanent: false);
    await OpenFile.open(file.path);
  }

  Future<void> _downloadAttachment(ImageContent a) async {
    final loaded = await _load(a);
    if (loaded == null || !mounted) return;
    final (_, bytes) = loaded;

    final file = await _writeFile(a, bytes, permanent: true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved ${a.title ?? 'file'}'),
        action: SnackBarAction(
          label: 'Open',
          onPressed: () => OpenFile.open(file.path),
        ),
      ),
    );
  }

  // TODO: backend returns status 1/2/3; confirm what each value means.
  String _statusText(int? status) => Utils.ppmMftStatusText(status);

  Widget _cancelButton() {
    return AppButton(
      width: Constants.cancelButtonWidth,
      backgroundColor: Colors.white,
      key: const Key(Keys.cancelButton),
      buttonText: Constants.close,
      buttonTextKey: Keys.cancelButton,
      onTap: () {
        Navigator.pop(context);
        CommonServices().unlock();
      },
    );
  }
}
