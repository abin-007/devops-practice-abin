///Show_image code , which is under lib/src/common_widgets/show_image

// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'package:db_atom/index.dart';
// import 'package:photo_view/photo_view.dart';

// class ShowImage extends StatelessWidget {
//   const ShowImage({super.key, required this.filePath, this.imageBytes});

//   final String? filePath;
//   final String? imageBytes;

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     double height = size.height;
//     return Scaffold(
//       backgroundColor: AppColors.black,
//       appBar: BaseAppBar().buildAppHeader(
//           context: context,
//           title: 'View Image',
//           showPopUp: false,
//           showSaveButton: false,
//           showSubmitButton: false,
//           showDisLikeButton: false,
//           showLikeButton: false,
//           showCustomIcon: true,
//           customIcon: Icons.download,
//           onTapCustomIcon: () async {
//             // Ask the user to save it
//             // final params = SaveFileDialogParams(sourceFilePath: filePath);
//             // final finalPath = await FlutterFileDialog.saveFile(params: params);
//             //
//             // if (finalPath != null) {
//             //   log('---File saved successfully---');
//             //   // message = 'File saved successfully';
//             // }

//             try {
//               SaveFileDialogParams? params;

//               if (!filePath.isEmptyOrNull) {
//                 params = SaveFileDialogParams(sourceFilePath: filePath);
//               } else if (!imageBytes.isEmptyOrNull) {
//                 params = SaveFileDialogParams(
//                   data: base64Decode(imageBytes!),
//                   fileName: 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
//                 );
//               }

//               if (params == null) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Nothing to download')),
//                 );
//                 return;
//               }

//               final finalPath = await FlutterFileDialog.saveFile(params: params);
//               if (finalPath != null) {
//                 log('---File saved successfully---');
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('File saved successfully')),
//                   );
//                 }
//               }
//             } catch (e) {
//               log('ShowImage download error: $e');
//             }
//           },
//       ),
//       body: Stack(
//         children: [
//           if (!imageBytes.isEmptyOrNull) ...[
//             Center(
//               child: Image.memory(
//                 Uint8List.fromList(
//                   base64Decode(
//                     imageBytes!,
//                   ),
//                 ),
//                 fit: BoxFit.contain,
//               ),
//             )
//           ] else ...[
//             !filePath.isEmptyOrNull
//                 ? PhotoView(
//                     imageProvider: FileImage(File(filePath!)),
//                   )
//                 : const Center(child: CircularProgressIndicator()),
//           ],
//           CommonWidgets.verticalSpacerWidget(height * 0.04),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 18.0),
//             child: Align(
//               alignment: Alignment.bottomCenter,
//               child: AppButton(
//                 width: Constants.cancelButtonWidth,
//                 backgroundColor: Colors.white,
//                 key: const Key(Keys.cancelButton),
//                 buttonText: Constants.close,
//                 buttonTextKey: Keys.cancelButton,
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ),
//           ),
//           CommonWidgets.verticalSpacerWidget(height * 0.07)
//         ],
//       ),
//     );
//   }
// }#