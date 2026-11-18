
import 'package:db_atom/src/features/createfound/models/user.dart';
import 'package:db_atom/src/models/base_object.dart';
import 'package:db_atom/src/models/organisation.dart';
import 'package:intl/intl.dart';

import '../../../../index.dart';

/// The list API returns the records under "list" ("data" comes back empty),
/// so we read "list" first and fall back to "data".
class PpmMftListResponseModel extends BaseObject {
  List<PpmMftModel>? items;
  int? totalCount;
  int? currentPageNo;
  int? totalPageCount;

  PpmMftListResponseModel({
    this.items,
    this.totalCount,
    this.currentPageNo,
    this.totalPageCount,
  });

  PpmMftListResponseModel.fromJson(Map<String, dynamic> json)
      : items = _readItems(json),
        totalCount = json['totalCount'] as int?,
        currentPageNo = json['currentPageNo'] as int?,
        totalPageCount = json['totalPageCount'] as int?;

  static List<PpmMftModel> _readItems(Map<String, dynamic> json) {
    final raw = (json['list'] as List?)?.isNotEmpty == true
        ? json['list'] as List
        : (json['data'] as List? ?? const []);
    return raw
        .map((e) => PpmMftModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Map<String, dynamic> toJson() => {
    'list': items?.map((e) => e.toJson()).toList(),
    'totalCount': totalCount,
    'currentPageNo': currentPageNo,
    'totalPageCount': totalPageCount,
  };
}

class PpmMftEngineer {
  int? id;
  String? engineerName;
  String? engineerMobile;

  PpmMftEngineer({this.id, this.engineerName, this.engineerMobile});

  factory PpmMftEngineer.fromJson(Map<String, dynamic> json) => PpmMftEngineer(
    id: json['id'] as int?,
    engineerName: json['engineerName'] as String?,
    engineerMobile: json['engineerMobile']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'engineerName': engineerName,
    'engineerMobile': engineerMobile,
  };
}

/// Fields taken from the real getPpmMftList response.
/// Dates (fromDate, toDate, inputDate) arrive as epoch SECONDS in a string.
class PpmMftModel extends BaseObject {
  int? id;
  String? slNo;
  String? eventName;
  String? followUp;
  String? comments;
  String? emailAddress;
  String? fromDate;
  String? toDate;
  String? inputDate;
  String? entrySecurityName;
  int? status;
  String? mailTo;
  String? mailToOtherUsers;
  int? requestType;
  List<PpmMftEngineer> engineers;
  List<ImageContent> attachments = [];
  // Not in the list response. Kept so the details screen compiles; fill from
  // the details API if it returns them.
  User? entrySecurity;
  Organisation? location;
  Organisation? locationRegion;
  List<Organisation> locations;
  List<Organisation> vendors;
  String? modifiedDate;
  String? modifiedBy;
  String? lock;

  PpmMftModel({
    this.id,
    this.slNo,
    this.eventName,
    this.followUp,
    this.comments,
    this.emailAddress,
    this.fromDate,
    this.toDate,
    this.inputDate,
    this.entrySecurityName,
    this.status,
    this.mailTo,
    this.mailToOtherUsers,
    this.requestType,
    this.engineers = const [],
    this.attachments = const [],
    this.entrySecurity,
    this.location,
    this.locationRegion,
    this.locations = const [],
    this.vendors = const [],
    this.modifiedDate,
    this.modifiedBy,
    this.lock,
  });

  factory PpmMftModel.fromJson(Map<String, dynamic> json) => PpmMftModel(
    id: json['id'] as int?,
    slNo: json['slNo'] as String?,
    eventName: json['eventName'] as String?,
    followUp: json['followUp'] as String?,
    comments: json['comments'] as String?,
    emailAddress: json['emailAddress'] as String?,
    fromDate: json['fromDate']?.toString(),
    toDate: json['toDate']?.toString(),
    inputDate: json['inputDate']?.toString(),
    // entrySecurity is a huge nested user/roles object; the list already
    // gives us the display name, so we do not parse it.
    entrySecurityName: json['entrySecurityName'] as String?,
    status: json['status'] as int?,
    mailTo: json['mailTo'] as String?,
    mailToOtherUsers: json['mailToOtherUsers'] as String?,
    requestType: json['requestType'] as int?,
    engineers: (json['ppmMftEngineers'] as List?)
        ?.map((e) => PpmMftEngineer.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [],
// new attachment is added
    attachments: (json['attachments'] as List? ?? [])
        .map((e) => ImageContent.fromJson(e as Map<String, dynamic>))
        .toList(),
    location: json['location'] is Map<String, dynamic>
        ? Organisation.fromJson(json['location'] as Map<String, dynamic>)
        : null,
    locationRegion: json['locationRegion'] is Map<String, dynamic>
        ? Organisation.fromJson(
        json['locationRegion'] as Map<String, dynamic>)
        : null,

    locations: _orgList(json['location']),
    vendors: _orgList(json['vendor']),
    modifiedDate: json['modifiedDate']?.toString(),
    modifiedBy: json['modifiedBy'] as String?,
    lock: json['lock'] as String?,
  );

  /// "1794681000" (epoch seconds) -> "15/11/2026". Empty string if missing.
  static String formatTs(String? seconds, {String pattern = 'dd/MM/yyyy'}) {
    final v = int.tryParse(seconds ?? '');
    if (v == null) return '';
    return DateFormat(pattern)
        .format(DateTime.fromMillisecondsSinceEpoch(v * 1000));
  }

  /// Accepts a list or a single object (the list API may still send an object).
  static List<Organisation> _orgList(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(Organisation.fromJson)
          .toList();
    }
    if (raw is Map<String, dynamic>) return [Organisation.fromJson(raw)];
    return [];
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'slNo': slNo,
    'eventName': eventName,
    'followUp': followUp,
    'comments': comments,
    'emailAddress': emailAddress,
    'fromDate': fromDate,
    'toDate': toDate,
    'inputDate': inputDate,
    'entrySecurityName': entrySecurityName,
    'status': status,
    'mailTo': mailTo,
    'mailToOtherUsers': mailToOtherUsers,
    'requestType': requestType,
    'ppmMftEngineers': engineers.map((e) => e.toJson()).toList(),
    'location': location?.toJson(),
    'locationRegion': locationRegion?.toJson(),
    'locations': locations.map((e) => e.toJson()).toList(),
    'vendor': vendors.map((e) => e.toJson()).toList(),
    'modifiedDate': modifiedDate,
    'modifiedBy': modifiedBy,
    'lock': lock,
  };
}

/// Create/update request wrapper. Change the key ('ppmMft') to what the backend expects.
class PpmMftRequest {
  final PpmMftModel? body;

  PpmMftRequest({this.body});

  Map<String, dynamic> toJson() => {'ppmMft': body?.toJson()};
}