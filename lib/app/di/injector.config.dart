// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:objectbox/objectbox.dart' as _i1034;

import '../../features/settings/data/models/app_settings_model.dart' as _i28;
import '../../features/settings/data/repositories/settings_repository_impl.dart'
    as _i955;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i674;
import '../../features/settings/domain/usecases/get_theme_preference.dart'
    as _i830;
import '../../features/settings/domain/usecases/save_theme_preference.dart'
    as _i375;
import '../../features/settings/presentation/bloc/theme/theme_bloc.dart'
    as _i242;
import '../../features/task/data/models/task_model.dart' as _i189;
import '../../features/task/data/repositories/task_repository_impl.dart'
    as _i325;
import '../../features/task/domain/repositories/task_repository.dart' as _i81;
import '../../features/task/domain/usecases/create_task.dart' as _i373;
import '../../features/task/domain/usecases/delete_task.dart' as _i227;
import '../../features/task/domain/usecases/get_my_day_tasks.dart' as _i211;
import '../../features/task/domain/usecases/get_tasks_by_list.dart' as _i378;
import '../../features/task/domain/usecases/toggle_task_completion.dart'
    as _i409;
import '../../features/task/domain/usecases/update_task.dart' as _i835;
import '../../features/task/presentation/bloc/my_day/my_day_bloc.dart' as _i948;
import '../../features/task/presentation/bloc/task_list/task_list_bloc.dart'
    as _i686;
import '../../features/todo_list/data/models/todo_list_model.dart' as _i727;
import '../../features/todo_list/data/repositories/todo_list_repository_impl.dart'
    as _i765;
import '../../features/todo_list/domain/entities/todo_list.dart' as _i409;
import '../../features/todo_list/domain/repositories/todo_list_repository.dart'
    as _i496;
import '../../features/todo_list/domain/usecases/create_list.dart' as _i345;
import '../../features/todo_list/domain/usecases/delete_list.dart' as _i401;
import '../../features/todo_list/domain/usecases/rename_list.dart' as _i784;
import '../../features/todo_list/domain/usecases/watch_lists.dart' as _i349;
import '../../features/todo_list/presentation/bloc/lists_overview/lists_overview_bloc.dart'
    as _i644;
import '../../objectbox.g.dart' as _i424;
import 'injector.dart' as _i811;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final databaseModule = _$DatabaseModule();
    await gh.singletonAsync<_i424.Store>(
      () => databaseModule.provideStore(),
      preResolve: true,
    );
    gh.singleton<_i424.Box<_i189.TaskModel>>(
      () => databaseModule.taskBox(gh<_i424.Store>()),
    );
    gh.singleton<_i424.Box<_i727.TodoListModel>>(
      () => databaseModule.listBox(gh<_i424.Store>()),
    );
    gh.singleton<_i424.Box<_i28.AppSettingsModel>>(
      () => databaseModule.settingsBox(gh<_i424.Store>()),
    );
    gh.lazySingleton<_i496.TodoListRepository>(
      () => _i765.TodoListRepositoryImpl(
        gh<_i1034.Box<_i727.TodoListModel>>(),
        gh<_i1034.Box<_i189.TaskModel>>(),
      ),
    );
    await gh.singletonAsync<_i409.TodoList>(
      () => databaseModule.provideDefaultList(gh<_i496.TodoListRepository>()),
      instanceName: 'defaultTodoList',
      preResolve: true,
    );
    gh.lazySingleton<_i81.TaskRepository>(
      () => _i325.TaskRepositoryImpl(gh<_i1034.Box<_i189.TaskModel>>()),
    );
    gh.lazySingleton<_i674.SettingsRepository>(
      () =>
          _i955.SettingsRepositoryImpl(gh<_i1034.Box<_i28.AppSettingsModel>>()),
    );
    gh.lazySingleton<_i373.CreateTask>(
      () => _i373.CreateTask(gh<_i81.TaskRepository>()),
    );
    gh.lazySingleton<_i227.DeleteTask>(
      () => _i227.DeleteTask(gh<_i81.TaskRepository>()),
    );
    gh.lazySingleton<_i211.GetMyDayTasks>(
      () => _i211.GetMyDayTasks(gh<_i81.TaskRepository>()),
    );
    gh.lazySingleton<_i378.GetTasksByList>(
      () => _i378.GetTasksByList(gh<_i81.TaskRepository>()),
    );
    gh.lazySingleton<_i409.ToggleTaskCompletion>(
      () => _i409.ToggleTaskCompletion(gh<_i81.TaskRepository>()),
    );
    gh.lazySingleton<_i835.UpdateTask>(
      () => _i835.UpdateTask(gh<_i81.TaskRepository>()),
    );
    gh.factory<_i686.TaskListBloc>(
      () => _i686.TaskListBloc(
        getTasksByList: gh<_i378.GetTasksByList>(),
        toggleTaskCompletion: gh<_i409.ToggleTaskCompletion>(),
        deleteTask: gh<_i227.DeleteTask>(),
        createTask: gh<_i373.CreateTask>(),
      ),
    );
    gh.lazySingleton<_i345.CreateList>(
      () => _i345.CreateList(gh<_i496.TodoListRepository>()),
    );
    gh.lazySingleton<_i401.DeleteList>(
      () => _i401.DeleteList(gh<_i496.TodoListRepository>()),
    );
    gh.lazySingleton<_i784.RenameList>(
      () => _i784.RenameList(gh<_i496.TodoListRepository>()),
    );
    gh.lazySingleton<_i349.WatchLists>(
      () => _i349.WatchLists(gh<_i496.TodoListRepository>()),
    );
    gh.factory<_i644.ListsOverviewBloc>(
      () => _i644.ListsOverviewBloc(
        watchLists: gh<_i349.WatchLists>(),
        createList: gh<_i345.CreateList>(),
        renameList: gh<_i784.RenameList>(),
        deleteList: gh<_i401.DeleteList>(),
      ),
    );
    gh.lazySingleton<_i830.GetThemePreference>(
      () => _i830.GetThemePreference(gh<_i674.SettingsRepository>()),
    );
    gh.lazySingleton<_i375.SaveThemePreference>(
      () => _i375.SaveThemePreference(gh<_i674.SettingsRepository>()),
    );
    gh.factory<_i242.ThemeBloc>(
      () => _i242.ThemeBloc(
        getThemePreference: gh<_i830.GetThemePreference>(),
        saveThemePreference: gh<_i375.SaveThemePreference>(),
      ),
    );
    gh.factory<_i948.MyDayBloc>(
      () => _i948.MyDayBloc(
        getMyDayTasks: gh<_i211.GetMyDayTasks>(),
        toggleTaskCompletion: gh<_i409.ToggleTaskCompletion>(),
        deleteTask: gh<_i227.DeleteTask>(),
        createTask: gh<_i373.CreateTask>(),
        defaultList: gh<_i409.TodoList>(instanceName: 'defaultTodoList'),
      ),
    );
    return this;
  }
}

class _$DatabaseModule extends _i811.DatabaseModule {}
