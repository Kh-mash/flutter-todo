import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/di/injector.dart';
import 'app/view/app.dart';
import 'core/simple_bloc_observer.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  Bloc.observer = SimpleBlocObserver();

  runApp(const App());
}
