import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//import 'core/errors/network/network_info.dart';
import 'features/onboarding_auth/data/datasources/auth_local_datasource.dart';
import 'features/onboarding_auth/data/datasources/auth_remote_datasource.dart';
import 'features/onboarding_auth/data/repositories/auth_repository_impl.dart';
import 'features/onboarding_auth/domain/repositories/auth_repository.dart';
import 'features/onboarding_auth/domain/usecases/auth_check.dart';
import 'features/onboarding_auth/domain/usecases/forget_password_usecase.dart';
import 'features/onboarding_auth/domain/usecases/getme_usecase.dart';
import 'features/onboarding_auth/domain/usecases/logout_usecase.dart';
import 'features/onboarding_auth/domain/usecases/reset_password_usecase.dart';
import 'features/onboarding_auth/domain/usecases/signIn_usecase.dart';
import 'features/onboarding_auth/domain/usecases/signup_usecase.dart';
import 'features/onboarding_auth/domain/usecases/verify_password_usecase.dart';
import 'features/onboarding_auth/domain/usecases/verifyotp_usecase.dart';

import 'features/onboarding_auth/presentation/pages/forget_password_page.dart';
import 'features/onboarding_auth/presentation/pages/onboarding_page.dart';
import 'features/onboarding_auth/presentation/pages/otp_page.dart';
import 'features/onboarding_auth/presentation/pages/reset_password_page.dart';
import 'features/onboarding_auth/presentation/pages/sign_in_page.dart';
import 'features/onboarding_auth/presentation/pages/sign_up_page.dart';
import 'features/onboarding_auth/presentation/pages/success_page.dart';
import 'features/onboarding_auth/presentation/bloc/auth_bloc.dart';
import 'features/onboarding_auth/presentation/bloc/auth_event.dart';
// import 'features/onboarding_auth/presentation/bloc/auth_state.dart';
// import 'features/profile/presentation/pages/profile_page.dart';
// import 'features/profile/domain/usecases/change_password_usecase.dart';
// import 'features/profile/domain/usecases/getprofile_usecase.dart';
// import 'features/profile/domain/usecases/logout_usecase.dart';
// import 'features/profile/domain/usecases/update_profile_usecase.dart';
// import 'features/profile/presentation/bloc/profile_bloc.dart';
// import 'features/profile/presentation/bloc/Profile_event.dart';
// import 'features/profile/presentation/bloc/profile_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  final authRepository = AuthRepositoryImpl(
    remoteDatasource: AuthRemoteDatasourceImpl(client: http.Client()),
    localDatasource: AuthLocalDatasourceImpl(secureStorage: secureStorage),
    //networkInfo: NetworkInfoImpl(connectionChecker: connectionChecker),
  );

  runApp(MyApp(authRepository: authRepository));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  const MyApp({super.key, required this.authRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(
        signUpUseCase: SignUpUseCase(authRepository),
        signInUseCase: SignInUseCase(authRepository),
        forgetPasswordUseCase: ForgetPasswordUseCase(authRepository),
        resetPasswordUseCase: ResetPasswordUseCase(authRepository),
        verifyOTPUseCase: VerifyOTPUseCase(authRepository),
        verifyPasswordUseCase: VerifyPasswordUseCase(authRepository),
        getMeUseCase: GetMeUseCase(authRepository),
        logoutUseCase: LogoutUseCase(authRepository),
        checkAuthStatusUseCase: CheckAuthStatusUseCase(authRepository),
        
      )..add(AppStarted()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'LawGen',
        theme: ThemeData(),
        home: const OnboardingPage(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/signup':
              return MaterialPageRoute(builder: (_) => const SignUpPage());
            case '/signin':
              return MaterialPageRoute(builder: (_) => const SignInPage());
            case '/forgotPassword':
              return MaterialPageRoute(
                builder: (_) => const ForgotPasswordPage(),
              );
            case '/resetpassword':
              final args = settings.arguments as String; // resetToken
              return MaterialPageRoute(
                builder: (_) => ResetPasswordPage(resetToken: args),
              );
            case '/otppage':
              final args = settings.arguments as String; // email
              return MaterialPageRoute(builder: (_) => OtpPage(email: args));
            case '/successreset':
              return MaterialPageRoute(
                builder: (_) => const SuccessResetPage(),
              );
            default:
              return MaterialPageRoute(builder: (_) => const SignInPage());
          }
        },
      ),
    );
  }
}
