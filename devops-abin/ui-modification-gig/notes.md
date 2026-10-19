
import 'dart:developer';

import 'package:db_atom/index.dart';


class _Ui {
  static const Color indigo = Color(0xFF150A78);
  static const Color indigoDark = Color(0xFF0B0545);
  static const Color gold = Color(0xFFD4A98A);
  static const Color goldLight = Color(0xFFE9CDB6);
  static const Color pageBg = Color(0xFFF4F3FB);
  static const Color cardBorder = Color(0xFFE6E3F5);
  static const Color fieldFill = Color(0xFFEFEBFB);
  static const Color fieldFillDisabled = Color(0xFFF4F2FA);
  static const Color fieldBorder = Color(0xFFC9C2EA);
  static const Color fieldBorderDisabled = Color(0xFFDDD8F2);
  static const Color hint = Color(0xFF6E65B5);

  static const LinearGradient indigoGradient = LinearGradient(
    colors: [indigo, indigoDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldLight, gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const TextStyle labelStyle = TextStyle(
    color: indigo,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle valueStyle = TextStyle(
    color: Colors.black,
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
}

// ---------------------------------------------------------------------------
// Reusable UI pieces
// ---------------------------------------------------------------------------

/// Tap-to-select field (replaces the old dark TextFieldAddButton look).
class _SelectorField extends StatelessWidget {
  final String? title;
  final String placeholder;
  final bool isDisabled;
  final VoidCallback onTap;

  const _SelectorField({
    required this.title,
    required this.isDisabled,
    required this.onTap,
    this.placeholder = 'Select',
  });

  @override
  Widget build(BuildContext context) {
    final hasTitle = title != null && title!.trim().isNotEmpty;

    return Material(
      color: isDisabled ? _Ui.fieldFillDisabled : _Ui.fieldFill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDisabled ? _Ui.fieldBorderDisabled : _Ui.fieldBorder,
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasTitle ? title! : placeholder,
                  style: hasTitle
                      ? _Ui.valueStyle
                      : const TextStyle(color: _Ui.hint, fontSize: 15),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: isDisabled ? null : _Ui.indigoGradient,
                  color: isDisabled ? _Ui.fieldBorderDisabled : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Read-only value box (used for "Created By", "Sl No." etc.).
class _ReadOnlyField extends StatelessWidget {
  final String value;

  const _ReadOnlyField({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _Ui.fieldFillDisabled,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _Ui.fieldBorderDisabled, width: 1.2),
      ),
      child: Text(value.trim(), style: _Ui.valueStyle),
    );
  }
}

class ContactDetailsView extends StatefulWidget {
  final ContactDetailModel? model;
  final String title;
  final ExtraProperties? extraProperties;

  const ContactDetailsView({
    super.key,
    this.model,
    required this.title,
    this.extraProperties,
  });

  @override
  State<ContactDetailsView> createState() => _ContactDetailsViewState();
}

class _ContactDetailsViewState extends State<ContactDetailsView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController returnableTextController = TextEditingController();
  User? userDetails;
  List<ImageContent> getFiles = [];
  List<ImageContent> getAttachments = [];
  TextEditingController takenOutOnDateController = TextEditingController();
  TextEditingController expectedDateOfReturnController =
      TextEditingController();
  TextEditingController actualDateOfReturnController = TextEditingController();
  bool isReadOnly = false;
  List<String> returnableDropDownValues = const [
    "Returnable",
    "Non Returnable",
  ];

  SignatureController receiverSignatureController = SignatureController();
  SignatureController securitySignatureController = SignatureController();

  @override
  void initState() {
    super.initState();
    receiverSignatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    securitySignatureController = SignatureController(
      penStrokeWidth: 2,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
    BlocProvider.of<ContactDetailsCubit>(context).initializeValues();
  }

  @override
  void dispose() {
    receiverSignatureController.dispose();
    securitySignatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double height = size.height;
    return BlocConsumer<ContactDetailsCubit, ContactDetailsState>(
      listener: (context, state) {
        log('--NN-state.status-${state.status}-------');
        Utils().formError(state, context);
        Utils().errorAndLogout(state, context);

        if (state.status == FormStatus.success) {
          var dialog = CustomAlertDialog(
            title: 'Escalation Matrix',
            message: state.message ?? '',
            positiveBtnText: Constants.ok,
            onPositivePressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.popAndPushNamed(context, contactDetailsListRoute);
            },
          );
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => dialog,
          );

          // Utils.dynamicAlert(
          //     context, state.message ?? '', 'Material Movement', '');
        }
      },
      builder: (context, state) {
        if (state.model.status == -1 || !state.model.lock.isEmptyOrNull) {
          isReadOnly = true;
        }
        if (state.model.status == 0 && !state.model.lock.isEmptyOrNull) {
          isReadOnly = true;
        }
        if (state.model.status == 1 && !state.model.lock.isEmptyOrNull) {
          isReadOnly = true;
        }

        if (widget.extraProperties != null &&
            !widget.extraProperties!.hasWritePermission!) {
          isReadOnly = true;
        }
        if (state.model.status == null) {
          isReadOnly = false;
        }

        return Scaffold(
          appBar: BaseAppBar().buildAppHeader(
            context: context,
            title: widget.title,
            showPopUp: false,
            showSaveButton: false,
            showSubmitButton: false,
            showDisLikeButton: false,
            showLikeButton: false,
            pdfAPIName:
                '${CommonApis.exportDetailPagePDF}${state.model.id}&moduleCode=${Constants.contactDetailsModuleCode}',
            popAndReplace: () {
              log('--popAndReplace-----');
              // Navigator.pop(context);
              Navigator.pop(context);
              Navigator.popAndPushNamed(context, contactDetailsListRoute);
            },
            onTapSave: () {
              FocusScope.of(context).unfocus();
              BlocProvider.of<ContactDetailsCubit>(
                context,
              ).submitForm(isSaveOnly: true, navigateToNextScreen: false);
            },
            onTapSubmit: () {
              FocusScope.of(context).unfocus();
              BlocProvider.of<ContactDetailsCubit>(
                context,
              ).submitForm(isSaveOnly: false, navigateToNextScreen: false);
            },
          ),
          backgroundColor: _Ui.pageBg,
          body:
          getBodybuilder(state, height),
        );
      },
    ); //BlocBuilder<CreateFoundArticleCubit, CreateFoundState>(
  }


  Widget getBodybuilder(ContactDetailsState state, double height) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: isReadOnly
                ? AutovalidateMode.disabled
                : AutovalidateMode.onUserInteraction,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!state.model.lock.isEmptyOrNull)
                    RecordLockedWidget(text: '${state.model.lock}'),
                  _section(
                    icon: Icons.info_outline_rounded,
                    title: Constants.generalinformation,
                    children: [
                      _field(
                        state.labels?.locale.entrySecurity ??
                            state.labels?.defaultLocale.entrySecurity ??
                            Constants.createdby,
                        _ReadOnlyField(value:
                          '${state.model.entrySecurity?.firstName ?? ''} ${state.model.entrySecurity?.lastName ?? ''}'),
                      ),
                      _field(
                        state.labels?.locale.status ??
                            state.labels?.defaultLocale.status ??
                            Constants.status,
                        _ReadOnlyField(value: getStatusString(state.model.status ?? 0)),
                      ),
                      _field(
                        state.labels?.locale.date ??
                            state.labels?.defaultLocale.date ??
                            Constants.dateofcreation,
                        dateCreateWidgetDisplay(state.model.inputDate ?? ''),
                      ),
                      _field(
                        state.labels?.locale.location ??
                            state.labels?.defaultLocale.location ??
                            Constants.location,
                        BaseLocationDropdown().locationWidgetDisplay(
                          isEnabled: false,
                          context: context,
                          locations: state.locations ?? Locations(),
                          selectedLocationName: state.model.location?.name ?? '',
                          onTap: (Organisation? location) {
                            BlocProvider.of<ContactDetailsCubit>(context)
                                .updateDropdownValues(location: location);
                          },
                        ),
                      ),
                      _field(
                        Constants.locationType,
                        _ReadOnlyField(value: state.model.locationType?.name ?? ''),
                      ),
                      _field(
                        state.labels?.locale.slNo ??
                            state.labels?.defaultLocale.slNo ??
                            Constants.slno,
                        _ReadOnlyField(value: state.model.slNo ?? ''),
                      ),
                      if (state.model.status != null) ...[
                        _field(
                          Constants.modifiedOn,
                          dateCreateWidgetDisplay(state.model.modifiedDate ?? ''),
                        ),
                        _field(
                          Constants.modifiedBy,
                          _ReadOnlyField(value:
                            '${state.loggedInUserDetails?.firstName ?? ''} ${state.loggedInUserDetails?.lastName ?? ''}'),
                        ),
                      ],
                    ],
                  ),
                  _section(
                    icon: Icons.contacts_outlined,
                    title: 'Contact Categories',
                    children: [
                      _contactLink(
                        title: state.labels?.locale.generalContact ?? state.labels?.defaultLocale.generalContact ?? Constants.generalContact,
                        onTap: () async {
                                NavigatorState nav = Navigator.of(context);
                                // bool isSaveSuccess =
                                //     await BlocProvider.of<ContactDetailsCubit>(
                                //             context)
                                //         .submitForm(
                                //   isSaveOnly: true,
                                //   navigateToNextScreen: true,
                                // );
                                //
                                // if (!isSaveSuccess) {
                                //   return;
                                // }
                                log('--state.model.id---${state.model.id}--');
                                List<Organisation> ranks =
                                    await CommonServices().getOrganisations(
                                  name: Constants.contactGeneralRank,
                                );

                                nav.pushNamed(
                                  contactRecordsRoute,
                                  arguments: {
                                    ConstantsArgument.title:
                                        Constants.generalContact,
                                    ConstantsArgument.keyLostType: 0,
                                    ConstantsArgument.id: state.model.id,
                                    ConstantsArgument.rankType:
                                        Constants.contactGeneralRank,
                                    ConstantsArgument.ranks: ranks,
                                    ConstantsArgument.parentStatus:
                                        state.model.status,
                                    ConstantsArgument.isLocked:
                                        state.model.lock,
                                  },
                                );
                              },
                      ),
                      _contactLink(
                        title: state.labels?.locale.guardingAgencyEscalationContact ?? state.labels?.defaultLocale.guardingAgencyEscalationContact ?? Constants.guardingAgencyContact,
                        onTap: () async {
                                NavigatorState nav = Navigator.of(context);
                                // bool isSaveSuccess =
                                //     await BlocProvider.of<ContactDetailsCubit>(
                                //             context)
                                //         .submitForm(
                                //   isSaveOnly: true,
                                //   navigateToNextScreen: true,
                                // );
                                //
                                // if (!isSaveSuccess) {
                                //   return;
                                // }
                                log('--state.model.id---${state.model.id}--');
                                List<Organisation> ranks =
                                    await CommonServices().getOrganisations(
                                  name: Constants
                                      .contactGuardingAgencyEscalationRank,
                                );
                                nav.pushNamed(
                                  contactRecordsRoute,
                                  arguments: {
                                    ConstantsArgument.title:
                                        Constants.guardingAgencyContact,
                                    ConstantsArgument.keyLostType: 1,
                                    ConstantsArgument.id: state.model.id,
                                    ConstantsArgument.rankType: Constants
                                        .contactGuardingAgencyEscalationRank,
                                    ConstantsArgument.ranks: ranks,
                                    ConstantsArgument.parentStatus:
                                        state.model.status,
                                    ConstantsArgument.isLocked:
                                        state.model.lock,
                                  },
                                );
                              },
                      ),
                      _contactLink(
                        title: state.labels?.locale.systemEscalationContact ?? state.labels?.defaultLocale.systemEscalationContact ?? Constants.systemEscalationContact,
                        onTap: () async {
                                NavigatorState nav = Navigator.of(context);
                                // bool isSaveSuccess =
                                //     await BlocProvider.of<ContactDetailsCubit>(
                                //             context)
                                //         .submitForm(
                                //   isSaveOnly: true,
                                //   navigateToNextScreen: true,
                                // );
                                //
                                // if (!isSaveSuccess) {
                                //   return;
                                // }
                                log('--state.model.id---${state.model.id}--');
                                List<Organisation> ranks =
                                    await CommonServices().getOrganisations(
                                  name: Constants.contactSystemEscalationRank,
                                );
                                nav.pushNamed(
                                  contactRecordsRoute,
                                  arguments: {
                                    ConstantsArgument.title:
                                        Constants.systemEscalationContact,
                                    ConstantsArgument.keyLostType: 2,
                                    ConstantsArgument.id: state.model.id,
                                    ConstantsArgument.rankType:
                                        Constants.contactSystemEscalationRank,
                                    ConstantsArgument.ranks: ranks,
                                    ConstantsArgument.parentStatus:
                                        state.model.status,
                                    ConstantsArgument.isLocked:
                                        state.model.lock,
                                  },
                                );
                              },
                      ),
                      _contactLink(
                        title: state.labels?.locale.supervisorRank ?? state.labels?.defaultLocale.supervisorRank ?? Constants.cmsEscalationContact,
                        onTap: () async {
                                NavigatorState nav = Navigator.of(context);
                                // bool isSaveSuccess =
                                //     await BlocProvider.of<ContactDetailsCubit>(
                                //             context)
                                //         .submitForm(
                                //   isSaveOnly: true,
                                //   navigateToNextScreen: true,
                                // );
                                //
                                // if (!isSaveSuccess) {
                                //   return;
                                // }
                                log('--state.model.id---${state.model.id}--');
                                List<Organisation> ranks =
                                    await CommonServices().getOrganisations(
                                  name: Constants.contactSupervisorRank,
                                );
                                nav.pushNamed(
                                  contactRecordsRoute,
                                  arguments: {
                                    ConstantsArgument.title:
                                        Constants.otherContact,
                                    ConstantsArgument.keyLostType: 4,
                                    ConstantsArgument.id: state.model.id,
                                    ConstantsArgument.rankType:
                                        Constants.contactSupervisorRank,
                                    ConstantsArgument.ranks: ranks,
                                    ConstantsArgument.parentStatus:
                                        state.model.status,
                                    ConstantsArgument.isLocked:
                                        state.model.lock,
                                  },
                                );
                              },
                      ),
                    ],
                  ),
                  Center(child: cancelButtonDisplay()),
                  SizedBox(height: height * 0.06),
                ],
              ),
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

  Widget _contactLink({required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: _Ui.fieldFill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _Ui.fieldBorder, width: 1.2),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: _Ui.indigoGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.people_outline_rounded,
                      color: _Ui.goldLight),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: _Ui.labelStyle),
                    const SizedBox(height: 5),
                    const Text('View Contact(s)', style: _Ui.valueStyle),
                  ],
                )),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: _Ui.indigo, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// White rounded card with an icon header and a gold underline.
  Widget _section({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _Ui.cardBorder),
        boxShadow: [
          BoxShadow(
            color: _Ui.indigo.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: _Ui.indigoGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: _Ui.goldLight, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: _Ui.indigo,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 2.5,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_Ui.gold, _Ui.gold.withValues(alpha: 0.0)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  /// A label (with optional red asterisk) above a field.
  Widget _field(String label, Widget child, {bool mandatory = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label, mandatory: mandatory),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _label(String text, {bool mandatory = true}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(child: Text(text, style: _Ui.labelStyle)),
        if (mandatory)
          const Text(
            ' *',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
          ),
      ],
    );
  }

  String getStatusString(int status) {
    switch (status) {
      case 0:
        return 'Draft';
      case 1:
        return 'Active';
      case -1:
        return 'Cancelled';
      default:
        return '';
    }
  }

  Widget cancelButtonDisplay() {
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

  // Widget cancelButtonDisplay(ContactDetailsState state) {
  //   log('--widget.model?.status---${widget.model?.status}----');
  //   bool condition = widget.model?.id == null ||
  //       widget.model?.status == ConstantsIntValue.cancelledStatus ||
  //       widget.model?.status == 3 ||
  //       !state.model.lock.isEmptyOrNull;
  //   return AppButton(
  //     width: Constants.cancelButtonWidth,
  //     backgroundColor: Colors.white,
  //     key: const Key(Keys.cancelButton),
  //     buttonText: condition ? Constants.close : Constants.cancelRecord,
  //     buttonTextKey: Keys.cancelButton,
  //     onTap: () {
  //       if (condition) {
  //         Navigator.pop(context);
  //         return;
  //       }
  //       var dialog = CustomAlertDialog(
  //           title: Constants.cancelRecord,
  //           message: Constants.cancelRecordWarningMessage,
  //           onPositivePressed: () {
  //             Navigator.pop(context);
  //             Navigator.pop(context);
  //             updateRecordStatus(state);
  //           },
  //           positiveBtnText: Constants.yes,
  //           negativeBtnText: Constants.no);
  //       showDialog(context: context, builder: (BuildContext context) => dialog);
  //     },
  //   );
  // }

  // void updateRecordStatus(ContactDetailsState state) {
  //   if (state.model.id != null) {
  //     BlocProvider.of<ContactDetailsCubit>(context)
  //         .updateStatus(id: state.model.id.toString());
  //     Navigator.popAndPushNamed(context, contactDetailsListRoute);
  //   } else {
  //     Navigator.pop(context);
  //   }
  // }

  Widget submitButtonDisplay() {
    return AppButton(
      width: 150,
      key: const Key(Keys.submitButton),
      buttonText: Constants.submit,
      buttonTextKey: Keys.submitButton,
      onTap: () async {
        FocusScope.of(context).unfocus();

        BlocProvider.of<ContactDetailsCubit>(context).submitForm();
      },
    );
  }

  Widget dateCreateWidgetDisplay(String date) {
    return FlutterInputField(
      key: ValueKey(date),
      textFormKey: Keys.dateofcreationTextController,
      initialValue: date,
      hintText: '',
      isEnable: false,
      isDisableColor: false,
      showBorder: true,
      onChange: (String value) {},
      validateTextField: (String? user) {},
    );
  }

// getById(int id, int type) async {
//   showLoadingDialog(context);
//
//   ContactListResponseModel contactsModel =
//   await ContactDetailsServices().getCdById(id, type);
//
//   editDataLoading(contactsModel);
// }
// void editDataLoading(ContactListResponseModel? model) {
//   dismissLoadingDialog(context);
//   if (model != null) {
//     Navigator.pushNamed(
//       context,
//       contactDetailsRoute,
//       arguments: {
//         "model": model,
//         "title": Constants.contactDetails,
//       },
//     );
//   }
// }
}

