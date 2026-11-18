// ##  card printing code for dart

// import 'dart:developer';

// import 'package:db_atom/index.dart';
// import 'package:db_atom/src/features/login/services/login_services.dart';

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<LoginBloc>(
//       create: (_) => LoginBloc(loginService: LoginService()),
//       child: const Login(),
//     );
//   }
// }

// class Login extends StatefulWidget {
//   const Login({super.key});

//   @override
//   State<Login> createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   static const _tabletBreakpoint = 600.0;
//   static const _phoneCardWidthFactor = 0.92;
//   static const _tabletCardWidthFactor = 0.6;
//   final _formKey = GlobalKey<FormState>();
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isPasswordVisible = false;

//   late Size _screenSize;
//   late double _cardWidth;

//   /// Used for fonts, icons, radii, paddings, field and button sizes,
//   /// so everything inside the card scales together.
//   double _ofCardWidth(double fraction) => _cardWidth * fraction;

//   /// Used for vertical gaps between sections.
//   double _ofScreenHeight(double fraction) => _screenSize.height * fraction;


//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _onLogin(LoginBloc bloc) {
//     FocusScope.of(context).unfocus();
//     if (!_formKey.currentState!.validate()) return;
//     log('Login requested');
//     bloc.add(
//       LoginVerifyEvent(
//         requestModel: LoginRequestModel(
//           request: Request(
//             userName: _usernameController.text.trim(),
//             password: _passwordController.text.trim(),
//             otp: '',
//           ),
//         ),
//         isFromLogin: true,
//       ),
//     );
//   }

//   void _onLoginState(BuildContext context, LoginState state) {
//     final bloc = context.read<LoginBloc>();
//     Utils().formError(state, context);

//     if (state is LoginLoadingState) {
//       showLoadingDialog(context);
//     } else if (state is LoginFailureState) {
//       dismissLoadingDialog(context);
//       showDialog(
//         context: context,
//         builder: (_) => CustomAlertDialog(
//           title: Constants.appName,
//           message: state.message,
//           positiveBtnText: Constants.ok,
//           onPositivePressed: () => Navigator.of(context).pop(),
//         ),
//       );
//     } else if (state is LoginSuccessState) {
//       dismissLoadingDialog(context);
//       Navigator.pushNamed(
//         context,
//         otpVerificationRoute,
//         arguments: {
//           'userDetails': VerifyOTPArguments(
//             bloc.userName,
//             bloc.password,
//             bloc.deviceToken,
//           ),
//         },
//       );
//     } else if (state is LoginVerifyOtpActionState) {
//       Navigator.pushNamedAndRemoveUntil(
//         context,
//         dashboardViewRoute,
//             (_) => false,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     _screenSize = MediaQuery.of(context).size;
//     final isTablet = _screenSize.shortestSide >= _tabletBreakpoint;
//     _cardWidth = _screenSize.shortestSide *
//         (isTablet ? _tabletCardWidthFactor : _phoneCardWidthFactor);
//     final bloc = context.read<LoginBloc>();

//     debugPrint('size=$_screenSize '
//         'orientation=${MediaQuery.of(context).orientation}');
//     log('Log1 ${_screenSize}');
//     log('Log2 ${MediaQuery.of(context).orientation}');

//     return Scaffold(
//       body: Stack(
//         children: [
//           _buildBackgroundGlow(const Alignment(-1.2, -0.8), const Color(0xFFCBD5F8)),
//           _buildBackgroundGlow(const Alignment(1.9, -0.9), const Color(0xFFFBDDBF)),
//           SafeArea(
//             child: BlocListener<LoginBloc, LoginState>(
//               listener: _onLoginState,
//               child: LayoutBuilder(
//                 builder: (context, constraints) => SingleChildScrollView(
//                   keyboardDismissBehavior:
//                   ScrollViewKeyboardDismissBehavior.onDrag,
//                   child: ConstrainedBox(
//                     constraints:
//                     BoxConstraints(minHeight: constraints.maxHeight),
//                     child: Align(
//                       alignment: Alignment.topCenter,
//                       child: Padding(
//                         padding: EdgeInsets.only(top: _ofScreenHeight(0.1)),
//                         child: SizedBox(
//                           width: _cardWidth,
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               FractionallySizedBox(
//                                 widthFactor: 0.6,
//                                 child: Image.asset(
//                                   'assets/images/GIG.png',
//                                   fit: BoxFit.contain,
//                                 ),
//                               ),
//                               SizedBox(height: _ofScreenHeight(0.03)),
//                               _buildCard(bloc),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCard(LoginBloc bloc) {
//     return Container(
//       padding: EdgeInsets.all(_ofCardWidth(0.055)),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.92),
//         borderRadius: BorderRadius.circular(_ofCardWidth(0.078)),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.navy.withValues(alpha: 0.08),
//             blurRadius: _ofCardWidth(0.11),
//             offset: Offset(0, _ofCardWidth(0.045)),
//           ),
//         ],
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeader(),
//             SizedBox(height: _ofScreenHeight(0.025)),
//             _buildLabel('Username'),
//             TextFormField(
//               controller: _usernameController,
//               textInputAction: TextInputAction.next,
//               autofillHints: const [AutofillHints.username],
//               style: TextStyle(fontSize: _ofCardWidth(0.042)),
//               decoration: _inputDecoration(
//                 hint: 'Enter username',
//                 icon: Icons.person_outline_rounded,
//               ),
//               validator: (v) =>
//               (v ?? '').trim().isEmpty ? 'Please enter username' : null,
//             ),
//             SizedBox(height: _ofScreenHeight(0.02)),
//             _buildLabel('Password'),
//             TextFormField(
//               controller: _passwordController,
//               obscureText: !_isPasswordVisible,
//               textInputAction: TextInputAction.done,
//               autofillHints: const [AutofillHints.password],
//               onFieldSubmitted: (_) => _onLogin(bloc),
//               style: TextStyle(fontSize: _ofCardWidth(0.042)),
//               decoration: _inputDecoration(
//                 hint: 'Enter password',
//                 icon: Icons.lock_outline_rounded,
//                 suffix: IconButton(
//                   onPressed: () => setState(
//                           () => _isPasswordVisible = !_isPasswordVisible),
//                   icon: Icon(
//                     _isPasswordVisible
//                         ? Icons.visibility_rounded
//                         : Icons.visibility_off_outlined,
//                     color: AppColors.hintColor,
//                     size: _ofCardWidth(0.06),
//                   ),
//                 ),
//               ),
//               validator: (v) =>
//               (v ?? '').trim().isEmpty ? 'Please enter password' : null,
//             ),
//             SizedBox(height: _ofScreenHeight(0.05)),
//             FilledButton(
//               onPressed: () => _onLogin(bloc),
//               style: FilledButton.styleFrom(
//                 backgroundColor: AppColors.navy,
//                 foregroundColor: Colors.white,
//                 minimumSize: Size.fromHeight(_ofCardWidth(0.155)),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(_ofCardWidth(0.045)),
//                 ),
//               ),
//               child: Text(
//                 'Sign in',
//                 style: TextStyle(
//                   fontSize: _ofCardWidth(0.045),
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       children: [
//         Container(
//           width: _ofCardWidth(0.145),
//           height: _ofCardWidth(0.145),
//           decoration: BoxDecoration(
//             color: AppColors.navy,
//             borderRadius: BorderRadius.circular(_ofCardWidth(0.04)),
//           ),
//           child: Icon(
//             Icons.login,
//             color: Colors.white,
//             size: _ofCardWidth(0.06),
//           ),
//         ),
//         SizedBox(width: _ofCardWidth(0.04)),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Login',
//                 style: TextStyle(
//                   color: AppColors.navy,
//                   fontSize: _ofCardWidth(0.061),
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               SizedBox(height: _ofScreenHeight(0.003)),
//               Text(
//                 'Security Operations Login',
//                 style: TextStyle(
//                   color: AppColors.hintColor,
//                   fontSize: _ofCardWidth(0.036),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLabel(String text) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: _ofScreenHeight(0.01)),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: AppColors.labelColor,
//           fontSize: _ofCardWidth(0.036),
//           fontWeight: FontWeight.w700,
//         ),
//       ),
//     );
//   }

//   InputDecoration _inputDecoration({
//     required String hint,
//     required IconData icon,
//     Widget? suffix,
//   }) {
//     OutlineInputBorder border(Color color, [double borderWidth = 1]) =>
//         OutlineInputBorder(
//           borderRadius: BorderRadius.circular(_ofCardWidth(0.045)),
//           borderSide: BorderSide(color: color, width: borderWidth),
//         );

//     return InputDecoration(
//       hintText: hint,
//       hintStyle: TextStyle(color: AppColors.hintColor, fontSize: _ofCardWidth(0.042)),
//       prefixIcon: Icon(icon, color: AppColors.indigo, size: _ofCardWidth(0.055)),
//       suffixIcon: suffix,
//       filled: true,
//       fillColor: Colors.white,
//       contentPadding: EdgeInsets.symmetric(vertical: _ofCardWidth(0.05)),
//       border: border(AppColors.borderColor),
//       enabledBorder: border(AppColors.borderColor),
//       focusedBorder: border(AppColors.navy, 1.5),
//       errorBorder: border(Colors.redAccent),
//       focusedErrorBorder: border(Colors.redAccent, 1.5),
//     );
//   }

//   Widget _buildBackgroundGlow(Alignment alignment, Color color) {
//     final glowSize = _screenSize.shortestSide * 1.1;
//     return Align(
//       alignment: alignment,
//       child: Container(
//         width: glowSize,
//         height: glowSize,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           gradient: RadialGradient(
//             colors: [color.withValues(alpha: 0.7), color.withValues(alpha: 0)],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class VerifyOTPArguments {
//   final String name;
//   final String pwd;
//   final String deviceToken;

//   VerifyOTPArguments(this.name, this.pwd, this.deviceToken);
// }
// '''