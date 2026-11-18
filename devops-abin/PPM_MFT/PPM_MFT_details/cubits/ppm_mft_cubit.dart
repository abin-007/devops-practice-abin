

import 'package:db_atom/index.dart';
import 'package:db_atom/src/features/PPM_MFT/models/ppm_mft_model.dart';
import 'package:db_atom/src/features/PPM_MFT/services/ppm_mft_services.dart';

part 'ppm_mft_state.dart';

class PpmMftCubit extends Cubit<PpmMftState> {
  final PpmMftServices services;
  final CommonServices commonServices;
  final PpmMftModel? model;

  PpmMftCubit({
    required this.services,
    required this.commonServices,
    this.model,
  }) : super(PpmMftState(model: model ?? PpmMftModel()));

  Future<void> initializeValues() async {
    emit(state.copyWith(status: FormStatus.loading));
    try {
      final userId = await SharedPrefs.getUserId();
      final User user = await commonServices.getUserDetails(userId: userId);

      final m = state.model;
      final isNew = m.id == null;
      if (isNew) {
        // New record: stamp creator and creation time (epoch seconds).
        m.entrySecurityName =
            '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
        m.inputDate =
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      }

      emit(state.copyWith(
        loggedInUserDetails: user,
        model: m,
        status: FormStatus.initial,
      ));
    } on Exception catch (e) {
      return UtilsCommon().exceptionHandling(e, emit, state);
    }
  }

  Future<bool> submitForm({bool isSaveOnly = false}) async {
    final validation = isSaveOnly ? state.isValidDraft : state.isValid;
    if (!validation.status) {
      emit(state.copyWith(
          status: FormStatus.formError, message: validation.message));
      return false;
    }

    emit(state.copyWith(status: FormStatus.loading));
    try {
      final response = await services.save(
        body: PpmMftRequest(body: state.model),
        isSubmit: !isSaveOnly,
      );
      final id = int.tryParse(response.id ?? '');
      if (id != null) state.model.id = id;

      emit(state.copyWith(
        model: state.model,
        message: response.message,
        status: FormStatus.success,
      ));
      return true;
    } on GenericResponse catch (e) {
      Utils().emitErrorState(e, emit, state);
      return false;
    } on Exception catch (e) {
      emit(state.copyWith(message: e.toString(), status: FormStatus.error));
      return false;
    }
  }
}