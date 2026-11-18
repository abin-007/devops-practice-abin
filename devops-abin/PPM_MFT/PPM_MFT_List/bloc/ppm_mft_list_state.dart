part of 'ppm_mft_list_bloc.dart';

class PpmMftListState extends Equatable {
  final List<PpmMftModel> items;
  final bool hasReachedMax;
  final FormStatus status;
  final String? message;
  final CommonFilters? commonFilters;
  final ExtraProperties? extraProperties;
  final DisplayMenu? displayMenu;

  const PpmMftListState({
    this.items = const <PpmMftModel>[],
    this.hasReachedMax = false,
    this.status = FormStatus.initial,
    this.message,
    this.commonFilters,
    this.extraProperties,
    this.displayMenu,
  });

  PpmMftListState copyWith({
    List<PpmMftModel>? items,
    bool? hasReachedMax,
    FormStatus? status,
    String? message,
    CommonFilters? commonFilters,
    ExtraProperties? extraProperties,
    DisplayMenu? displayMenu,
  }) {
    return PpmMftListState(
      items: items ?? this.items,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      status: status ?? this.status,
      message: message ?? this.message,
      commonFilters: commonFilters ?? this.commonFilters,
      extraProperties: extraProperties ?? this.extraProperties,
      displayMenu: displayMenu ?? this.displayMenu,
    );
  }

  @override
  List<Object?> get props => [
    items,
    hasReachedMax,
    status,
    message,
    commonFilters,
    extraProperties,
    displayMenu,
  ];
}