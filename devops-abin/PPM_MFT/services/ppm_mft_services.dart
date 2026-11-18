import 'package:db_atom/index.dart';
import 'package:db_atom/src/features/PPM_MFT/models/ppm_mft_model.dart';

class PpmMftConfig {
  // TEMP: reusing the escalation matrix module code so filters/permissions load.
  static const String moduleCode = Constants.contactDetailsModuleCode;
  static const String title = 'PPM, MFT List';
  static const String listTitle = 'PPM, MFT List';
}

class PpmMftApis {
  static final String baseUrl = Environment().config.apiHost;

  // TODO(backend): replace with real endpoints.
  static final String list = '$baseUrl/getPpmMftList?';
  static final String byId = '$baseUrl/getPpmMftById';
  static final String create = '$baseUrl/createPpmMft?';
}

class PpmMftServices {
  static final List<PpmMftModel> _db = List.generate(45, (i) {
    final regions = ['South', 'North', 'East', 'West'];
    final locations = ['Bengaluru', 'Delhi', 'Kolkata', 'Mumbai'];
    return PpmMftModel.fromJson({
      'id': i + 1,
      'slNo': 'PPM-MFT-${(i + 1).toString().padLeft(4, '0')}',
      'location': {'id': (i % 4) + 1, 'name': locations[i % 4]},
      'locationRegion': {'id': (i % 4) + 1, 'name': regions[i % 4]},
      'inputDate':
          (DateTime.now().subtract(Duration(days: i)).millisecondsSinceEpoch ~/
                  1000)
              .toString(),
      'entrySecurity': {'firstName': 'Demo', 'lastName': 'User ${i + 1}'},
      'status': i % 3 == 0 ? 0 : 1,
    });
  });

  Future<PpmMftListResponseModel> getList({
    required String startPosition,
    required String maximumRecords,
    required BaseFilterModel filters,
  }) async {
    final String url =
        '${PpmMftApis.list}startPos=$startPosition&maxResults=$maximumRecords';
    final response = await BaseApiService().postRequest(
      requestedData: filters.toJson(),
      isAuthenticated: true,
      url: url,
    );
    return PpmMftListResponseModel.fromJson(response);
  }

  Future<PpmMftModel> getById(int id) async {
    final response =
        await BaseApiService().getRequest(url: '${PpmMftApis.byId}/$id');
    return PpmMftModel.fromJson(response);
  }

  Future<GenericResponse> save({
    required PpmMftRequest body,
    required bool isSubmit,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final model = body.body!;
    model.status = isSubmit ? 1 : 0;
    final index = _db.indexWhere((e) => e.id == model.id);
    if (index >= 0) {
      _db[index] = model;
    } else {
      model.id = _db.length + 1;
      _db.insert(0, model);
    }
    return GenericResponse.fromJson({
      'message': isSubmit ? 'Submitted successfully' : 'Saved as draft',
      'id': model.id.toString(),
    });
  }
}
