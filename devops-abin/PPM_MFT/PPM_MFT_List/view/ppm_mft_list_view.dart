import 'dart:developer';
import 'dart:ui';

import 'package:db_atom/index.dart';
import 'package:db_atom/src/features/PPM_MFT/models/ppm_mft_model.dart';
import 'package:db_atom/src/features/PPM_MFT/services/ppm_mft_services.dart';

import 'package:db_atom/src/features/PPM_MFT/PPM_MFT_List/bloc/ppm_mft_list_bloc.dart';

class PpmMftListView extends StatefulWidget {
  const PpmMftListView({super.key});

  @override
  State<PpmMftListView> createState() => _PpmMftListViewState();
}

class _PpmMftListViewState extends State<PpmMftListView> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BaseFilterModel filters = BaseFilterModel();

  PpmMftListBloc get _bloc => context.read<PpmMftListBloc>();

  @override
  void initState() {
    super.initState();

    _bloc.add(const PpmMftInitialize());

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final s = _bloc.state;

    if (s.status == FormStatus.loading || s.hasReachedMax) {
      return;
    }

    final pos = _scrollController.position;

    if (pos.pixels >= pos.maxScrollExtent - 50) {
      _bloc.add(
        PpmMftFetch(
          startPos: s.items.length,
          maxPos: Constants.maxResults,
          newSearch: false,
          filters: filters,
        ),
      );
    }
  }

  Future<void> _onRefresh() async {
    _bloc.add(const PpmMftRefresh());

    await Future.delayed(
      const Duration(milliseconds: 800),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PpmMftListBloc, PpmMftListState>(
      listener: (context, state) {
        Utils().formError(state, context);
        Utils().errorAndLogout(state, context);

        if (state.status == FormStatus.sessionExpired) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                state.message ?? 'Session Expired...',
              ),
            ),
          );

          Validator.logoutAction(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          key: _scaffoldKey,

          backgroundColor: Colors.transparent,

          extendBody: true,

          // FIX: Prevent body from extending
          // behind the AppBar.
          extendBodyBehindAppBar: false,

          bottomNavigationBar: CustomBottomNavigationBar(
            scaffoldKey: _scaffoldKey,
            context: context,
            hasAddPermission: false,
            displayMenu: state.displayMenu,
            list: true,
            onAddPressed: () {},
          ),

          appBar: BaseAppBar().buildAppHeader(
            context: context,
            title: PpmMftConfig.listTitle,
            showPopUp: true,
            showSaveButton: false,
            showSubmitButton: false,
            showDisLikeButton: false,
            showLikeButton: false,
            excelAPIName: '',
            pdfAPIName: '',
          ),

          body: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/bg2.png',
                  fit: BoxFit.cover,
                ),
              ),

              // Background blur
              Positioned.fill(
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 80,
                      sigmaY: 80,
                    ),
                    child: Container(
                      color: Colors.black.withValues(
                        alpha: 0.2,
                      ),
                    ),
                  ),
                ),
              ),

              // Search bar and list
              Column(
                children: [
                  const SizedBox(height: 12),

                  // Search + filter
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    child: BaseSearchWidget(
                      applySearchFilters: applySearchFilters,
                      applyFilters: applyFilters,
                      commonFilters: state.commonFilters ??
                          CommonFilters(
                            statuses: [],
                            regions: [],
                          ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // List fills remaining height
                  Expanded(
                    child: CustomMaterialIndicator(
                      onRefresh: _onRefresh,
                      backgroundColor: Colors.white,
                      indicatorBuilder: (context, controller) => const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: BaseLoader(),
                      ),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.only(
                          bottom: 100,
                        ),
                        itemCount: state.hasReachedMax
                            ? state.items.length
                            : state.items.length + 1,
                        itemBuilder: (context, index) {
                          if (index >= state.items.length) {
                            return state.status == FormStatus.loading ||
                                    state.status == FormStatus.initial
                                ? const Center(
                                    child: BaseLoader(),
                                  )
                                : const SizedBox();
                          }

                          return _buildItem(
                            state.items[index],
                            index,
                            state,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItem(
    PpmMftModel item,
    int index,
    PpmMftListState state,
  ) {
    final labels = <Label>[
      Label(
        key: Constants.slno,
        value: item.slNo ?? '',
      ),
      Label(
        key: 'Location',
        value: item.location?.name ??
            item.locations.map((e) => e.name ?? '').join(', '),
      ),
      Label(
        key: Constants.createdby,
        value: item.entrySecurityName ?? '',
      ),
      // Label(
      //   key: 'Event Name',
      //   value: item.eventName ?? '',
      // ),
      Label(
        key: 'Engineer Name',
        value: item.followUp ?? '',
      ),
      Label(
        key: 'Date of Creation',
        value: PpmMftModel.formatTs(item.inputDate) ?? '',
      )
      // Label(
      //   key: 'Reference No.',
      //   value: item.emailAddress ?? '',
      // ),
      // Label(
      //   key: 'From Date',
      //   value: PpmMftModel.formatTs(
      //     item.fromDate,
      //   ),
      // ),
      // Label(
      //   key: 'To Date',
      //   value: PpmMftModel.formatTs(
      //     item.toDate,
      //   ),
      // ),
    ];

    return _GlassCard(
      child: BaseListTileItem(
        id: item.id,
        labels: labels,
        status: item.status,
        isEventProtectionStatus: false,
        isContactDetailsStatus: false,
        isPpmMftStatus: true,
        showEditButton: false,
        index: index,
        onTap: (_) => _showPopup(item, labels),
        onViewTap: (_) => _showPopup(item, labels),
        onEditTap: (_) => _openDetails(
          state.extraProperties?.hasWritePermission ?? false,
          item,
        ),
      ),
    );
  }

  void _showPopup(
    PpmMftModel item,
    List<Label> labels,
  ) {
    showDialog(
      context: context,
      builder: (_) => Material(
        type: MaterialType.transparency,
        child: BasePopUpItems(
          id: item.id.toString(),
          labels: labels,
          status: item.status,
          isContactDetailsStatus: false,
          isPpmMftStatus: true,
          isEventProtectionStatus: false,
          isMasterGuard: false,
        ),
      ),
    );
  }

  // void _openDetails(
  //   bool hasWritePermission,
  //   PpmMftModel model,
  // ) {
  //   Navigator.pushNamed(
  //     context,
  //     ppmMftRoute,
  //     arguments: {
  //       'model': model,
  //       'title': PpmMftConfig.title,
  //       ConstantsArgument.extraProperties: ExtraProperties(
  //         hasWritePermission: hasWritePermission,
  //       ),
  //     },
  //   );
  // }
  Future<void> _openDetails(bool hasWritePermission, PpmMftModel item) async {
    showLoadingDialog(context);

    PpmMftModel? model;
    try {
      model = await PpmMftServices().getById(item.id ?? 0);
    } on Exception catch (e) {
      log('PpmMft getById error: $e');
    }

    if (!mounted) return;
    dismissLoadingDialog(context);

    if (model == null) return; // or show an error / fall back to `item`

    Navigator.pushNamed(
      context,
      ppmMftRoute,
      arguments: {
        'model': model,
        'title': PpmMftConfig.title,
        ConstantsArgument.extraProperties:
        ExtraProperties(hasWritePermission: hasWritePermission),
      },
    );
  }

  void applySearchFilters(
    FilterCriteria model,
  ) {
    filters = BaseFilterModel(
      filterCriteria: model,
    );

    _bloc.add(
      PpmMftFetch(
        startPos: 0,
        maxPos: Constants.maxResults,
        newSearch: true,
        filters: filters,
      ),
    );
  }

  void applyFilters(Filters model) {
    filters = BaseFilterModel(
      filterCriteria: FilterCriteria(
        filters: model,
      ),
    );

    _bloc.add(
      PpmMftFetch(
        startPos: 0,
        maxPos: Constants.maxResults,
        newSearch: true,
        filters: filters,
      ),
    );

    Navigator.pop(context);
  }
}

// Glass-effect card
class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 18,
            sigmaY: 18,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(
                    alpha: 0.09,
                  ),
                  Colors.transparent,
                  Colors.white.withValues(
                    alpha: 0.09,
                  ),
                ],
                stops: const [
                  0.02,
                  0.35,
                  1,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(27),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.6,
                ),
                width: 0.7,
              ),
            ),

            // Transparent Material gives
            // ListTile its own ink surface.
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
