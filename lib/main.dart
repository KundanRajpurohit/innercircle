// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:innercircle/blocs/auth/auth_bloc.dart';
import 'package:innercircle/blocs/auth/auth_event.dart';
import 'package:innercircle/blocs/events/events_bloc.dart';
import 'package:innercircle/blocs/profile/profile_bloc.dart';
import 'package:innercircle/data/repositries/auth_repository.dart';
import 'package:innercircle/data/repositries/firebase_service.dart';
import 'package:innercircle/data/repositries/location_repo.dart';
import 'package:innercircle/presentation/screens/auth/splash_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TogetherApp());
}

class TogetherApp extends StatelessWidget {
  const TogetherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(create: (context) => AuthService()),
        RepositoryProvider<FirestoreService>(
          create: (context) => FirestoreService(),
        ),
        RepositoryProvider<LocationService>(
          create: (context) => LocationService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create:
                (context) => AuthBloc(
                  authService: context.read<AuthService>(),
                  locationService: context.read<LocationService>(),
                )..add(AuthCheckRequested()),
          ),
          BlocProvider<EventsBloc>(
            create:
                (context) => EventsBloc(
                  firestoreService: context.read<FirestoreService>(),
                ),
          ),
          BlocProvider<ProfileBloc>(
            create:
                (context) =>
                    ProfileBloc(authService: context.read<AuthService>()),
          ),
        ],
        child: MaterialApp(
          title: 'Together',
          theme: TogetherTheme.lightTheme,
          darkTheme: TogetherTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
