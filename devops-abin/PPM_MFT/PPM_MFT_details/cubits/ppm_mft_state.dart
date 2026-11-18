

part of 'ppm_mft_cubit.dart';

class PpmMftState extends Equatable {
  final FormStatus status;
  final PpmMftModel model;
  final Locations? locations;
  final User? loggedInUserDetails;
  final String? message;

  const PpmMftState({
    this.status = FormStatus.initial,
    required this.model,
    this.locations,
    this.loggedInUserDetails,
    this.message,
  });

  // TODO(backend): adjust validations once create/update is defined.
  ErrorResponse get isValidDraft {
    if (model.entrySecurityName.isEmptyOrNull) {
      return const ErrorResponse(
          status: false, message: 'Created By is required');
    }
    if (model.inputDate == null) {
      return const ErrorResponse(
          status: false, message: 'Created Date is required');
    }
    return const ErrorResponse(status: true, message: 'Form is Valid');
  }

  ErrorResponse get isValid => isValidDraft;

  // The model is mutated in place, so include changing fields to force rebuilds.
  @override
  List<Object?> get props => [
    model,
    model.slNo,
    model.status,
    status,
    message,
    locations,
    loggedInUserDetails,
  ];

  PpmMftState copyWith({
    FormStatus? status,
    PpmMftModel? model,
    Locations? locations,
    User? loggedInUserDetails,
    String? message,
  }) {
    return PpmMftState(
      status: status ?? this.status,
      model: model ?? this.model,
      locations: locations ?? this.locations,
      loggedInUserDetails: loggedInUserDetails ?? this.loggedInUserDetails,
      message: message ?? this.message,
    );
  }
}