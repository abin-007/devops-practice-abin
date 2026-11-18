import 'dart:async';
import 'dart:developer';

import 'package:db_atom/index.dart';
import 'package:db_atom/src/features/PPM_MFT/models/ppm_mft_model.dart';
import 'package:db_atom/src/features/PPM_MFT/services/ppm_mft_services.dart';


part 'ppm_mft_list_event.dart';
part 'ppm_mft_list_state.dart';

class PpmMftListBloc extends Bloc<PpmMftListEvent, PpmMftListState> {
  PpmMftListBloc() : super(const PpmMftListState()) {
    on<PpmMftInitialize>(_initialize);
    on<PpmMftFetch>(_fetch, transformer: droppable());
    on<PpmMftRefresh>(_refresh, transformer: droppable());
  }

  final PpmMftServices services = PpmMftServices();
  final CommonServices commonServices = CommonServices();

  /// Last applied filters, so pull-to-refresh keeps them.
  BaseFilterModel _filters = BaseFilterModel();

  FutureOr<void> _initialize(
      PpmMftInitialize event, Emitter<PpmMftListState> emit) async {
    try {
      emit(state.copyWith(status: FormStatus.loading));

      final ExtraProperties extraProperties =
      await UtilsCommon().checkWritePermission(
        moduleCode: PpmMftConfig.moduleCode,
        commonServices: commonServices,
      );
      final List<Organisation> statuses = await commonServices
          .getStatusesByModuleId(module: PpmMftConfig.moduleCode);
      final List<Organisation> regions =
      await commonServices.getRegionsOrLocationsByRegionId();

      emit(
        state.copyWith(
          commonFilters: CommonFilters(regions: regions, statuses: statuses),
          extraProperties: extraProperties,
          hasReachedMax: false,
          status: FormStatus.initial,
        ),
      );

      add(PpmMftFetch(
        startPos: 0,
        maxPos: Constants.maxResults,
        newSearch: true,
        filters: _filters,
      ));
    } on GenericResponse catch (e) {
      emit(state.copyWith(message: e.message, status: FormStatus.formError));
    } on Exception catch (e) {
      return UtilsCommon().exceptionHandling(e, emit, state);
    }
  }

  FutureOr<void> _refresh(
      PpmMftRefresh event, Emitter<PpmMftListState> emit) async {
    try {
      final response = await services.getList(
        startPosition: '0',
        maximumRecords: '${Constants.maxResults}',
        filters: _filters,
      );
      final fetched = response.items ?? [];
      emit(
        state.copyWith(
          items: fetched,
          hasReachedMax: fetched.length < Constants.maxResults,
          status: FormStatus.success,
        ),
      );
    } on Exception catch (e) {
      return UtilsCommon().exceptionHandling(e, emit, state);
    }
  }

  FutureOr<void> _fetch(
      PpmMftFetch event, Emitter<PpmMftListState> emit) async {
    if (!event.newSearch && state.hasReachedMax) return;
    emit(state.copyWith(status: FormStatus.loading));

    try {
      if (event.newSearch) _filters = event.filters;

      final response = await services.getList(
        startPosition: '${event.startPos}',
        maximumRecords: '${event.maxPos}',
        filters: event.newSearch ? event.filters : _filters,
      );
      final fetched = response.items ?? [];

      if (event.newSearch) {
        return emit(
          state.copyWith(
            items: fetched,
            hasReachedMax: fetched.length < event.maxPos,
            status: FormStatus.success,
          ),
        );
      }

      emit(
        state.copyWith(
          items: List.of(state.items)..addAll(fetched),
          hasReachedMax: fetched.isEmpty || fetched.length < event.maxPos,
          status: FormStatus.success,
        ),
      );
    } on TokenExpiredException catch (e) {
      emit(state.copyWith(
          message: e.message, status: FormStatus.sessionExpired));
    } catch (e,st) {
      log('PpmMft fetch error: $e\n$st');
      emit(state.copyWith(status: FormStatus.failure));
    }
  }
}