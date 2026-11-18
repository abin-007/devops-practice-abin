part of 'ppm_mft_list_bloc.dart';

abstract class PpmMftListEvent extends Equatable {
  const PpmMftListEvent();

  @override
  List<Object?> get props => [];
}

class PpmMftFetch extends PpmMftListEvent {
  final int startPos;
  final int maxPos;
  final bool newSearch;
  final BaseFilterModel filters;

  const PpmMftFetch({
    required this.startPos,
    required this.maxPos,
    required this.newSearch,
    required this.filters,
  });

  @override
  List<Object?> get props => [startPos, maxPos, newSearch];
}

class PpmMftInitialize extends PpmMftListEvent {
  const PpmMftInitialize();
}

class PpmMftRefresh extends PpmMftListEvent {
  const PpmMftRefresh();
}