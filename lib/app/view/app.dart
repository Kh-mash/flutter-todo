import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/settings/domain/entities/theme_preference.dart';
import '../../features/settings/presentation/bloc/theme/theme_bloc.dart';
import '../../features/settings/presentation/bloc/theme/theme_event.dart';
import '../../features/settings/presentation/bloc/theme/theme_state.dart';
import '../di/injector.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ThemeBloc>()..add(const ThemeSubscriptionRequested()),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final themeMode = switch (state.preference) {
            ThemePreference.system => ThemeMode.system,
            ThemePreference.light => ThemeMode.light,
            ThemePreference.dark => ThemeMode.dark,
          };
          return MaterialApp.router(
            title: 'Flutter Todo',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
