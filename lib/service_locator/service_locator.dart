import 'package:get_it/get_it.dart';
import 'package:youtube_comment_picker/bloc/landing/landing_bloc.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Registers shared services and blocs.
void setupServiceLocator() {
  if (getIt.isRegistered<LandingBloc>()) {
    return;
  }

  getIt.registerSingleton<LandingBloc>(
    LandingBloc(),
    dispose: (bloc) => bloc.close(),
  );
}
