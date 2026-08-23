import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/theme_preference.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_event.dart';
import '../bloc/theme/theme_state.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final icon = switch (state.preference) {
          ThemePreference.system => Icons.brightness_auto,
          ThemePreference.light => Icons.light_mode,
          ThemePreference.dark => Icons.dark_mode,
        };
        return IconButton(
          tooltip: 'Theme: ${state.preference.name}',
          icon: Icon(icon),
          onPressed: () => context.read<ThemeBloc>().add(const ThemeCycled()),
        );
      },
    );
  }
}
