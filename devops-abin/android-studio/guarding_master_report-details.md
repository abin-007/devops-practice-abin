# Guarding Master Data Details — UI Migration Report

Reference visual system: Article Found Details page (indigo/gold header, lavender controls, white rounded cards).

## Changes in the updated file (line numbers refer to `GuardingMasterDataDetailsView_updated.dart`)

| Line(s) | Change | Details |
|---|---|---|
| 7–38 | Added | `_GuardUi` palette, typography, gradients and shared colors. |
| 40–85 | Added | `_GuardSelector` to replace `TextFieldAddButton` while retaining the same constructor parameters and onTap callbacks. |
| 243 | Modified | Scaffold background set to `_GuardUi.pageBg`. |
| 252–288 | Added | `_guardSection` rounded white card, indigo gradient header, gold-tinted icon, card border and shadow. |
| 472–642 | Redesigned | General Information card including record metadata and location/entity values. |
| 643–1404 | Redesigned | Guard Profile card, including guard photo, vendor, employment, demographic and deployment fields. |
| 1405–1511 | Redesigned | Deployment Information card, including conditional deployment order attachment. |
| 1512–1864 | Redesigned | Physical & Language Details card. |
| 1865–2058 | Redesigned | Address & Verification card and attachment widgets. |
| 2059–2430 | Redesigned | Qualifications & Certification card, dates and uploads. |
| 2431–2736 | Redesigned | Employment & Compliance card. |
| 2737–3272 | Redesigned | Health & Training card, including dynamic fields and modified metadata. |
| Across file | Modified | Old white label styles replaced with readable indigo label style, and active selector controls updated. |
| Body view | Removed | Background image and heavy `BackdropFilter`, leaving a solid light page background. |

## Preserved

- Existing `GuardingMasterDataDetailsCubit`, initialization, submit handlers, save flags and PDF export name.
- Existing read-only and lock logic, conditional branches, field controllers, validation and data bindings.
- Upload and attachment widgets, file selection callbacks, existing module codes and download/delete flags.
- Existing status dropdown, date picker and radio/checkbox behavior, including their enabled/disabled flags.
- Close/cancel navigation and the rest of the helper methods.

## Validation notes

- Source and generated file passed a structural delimiter-balance check (`()`, `[]`, `{}`), skipping comments and strings.
- **Not Flutter-compiled or device-tested:** the full `db_atom` Flutter project and its imports/dependencies are not available here.
- Custom form widgets (`FlutterInputField`, `BaseDropDown`, `BaseDate`, upload controls, etc.) retain their native inner styling; the new palette applies to sections, labels and replaced selector widgets.
- Please run `dart format` and `flutter analyze` in your own project and check small-screen overflow, conditional visibility, attachments and navigation.
