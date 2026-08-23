import 'package:flutter_todo/features/settings/data/models/app_settings_model.dart';
import 'package:flutter_todo/features/task/data/models/task_model.dart';
import 'package:flutter_todo/features/todo_list/data/models/todo_list_model.dart';
import 'package:flutter_todo/features/todo_list/domain/entities/todo_list.dart';
import 'package:flutter_todo/features/todo_list/domain/repositories/todo_list_repository.dart';
import 'package:flutter_todo/objectbox.g.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'injector.config.dart';

final getIt = GetIt.instance;

@InjectableInit(preferRelativeImports: true)
Future<void> configureDependencies() async => getIt.init();

@module
abstract class DatabaseModule {
  @preResolve
  @singleton
  Future<Store> provideStore() async {
    final dir = await getApplicationSupportDirectory();
    return openStore(directory: p.join(dir.path, 'objectbox'));
  }

  @singleton
  Box<TaskModel> taskBox(Store store) => store.box();

  @singleton
  Box<TodoListModel> listBox(Store store) => store.box();

  @singleton
  Box<AppSettingsModel> settingsBox(Store store) => store.box();

  @preResolve
  @Named('defaultTodoList')
  @singleton
  Future<TodoList> provideDefaultList(TodoListRepository repository) =>
      repository.ensureDefaultList().then(
            (result) => result.fold(
              (failure) => throw StateError(
                'Failed to seed default list: ${failure.message}',
              ),
              (list) => list,
            ),
          );
}
