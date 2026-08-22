import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/create_list.dart';
import '../../../domain/usecases/delete_list.dart';
import '../../../domain/usecases/rename_list.dart';
import '../../../domain/usecases/watch_lists.dart';
import 'lists_overview_event.dart';
import 'lists_overview_state.dart';

class ListsOverviewBloc extends Bloc<ListsOverviewEvent, ListsOverviewState> {
  ListsOverviewBloc({
    required WatchLists watchLists,
    required CreateList createList,
    required RenameList renameList,
    required DeleteList deleteList,
  })  : _watchLists = watchLists,
        _createList = createList,
        _renameList = renameList,
        _deleteList = deleteList,
        super(const ListsOverviewState()) {
    on<ListsOverviewSubscriptionRequested>(_onSubscription);
    on<ListsOverviewCreateRequested>(_onCreate);
    on<ListsOverviewRenameRequested>(_onRename);
    on<ListsOverviewDeleteRequested>(_onDelete);
  }

  final WatchLists _watchLists;
  final CreateList _createList;
  final RenameList _renameList;
  final DeleteList _deleteList;

  Future<void> _onSubscription(
    ListsOverviewSubscriptionRequested event,
    Emitter<ListsOverviewState> emit,
  ) async {
    emit(state.copyWith(status: ListsOverviewStatus.loading));
    await emit.forEach(
      _watchLists(),
      onData: (result) => result.fold(
        (f) => state.copyWith(
            status: ListsOverviewStatus.failure, errorMessage: f.message),
        (lists) => state.copyWith(
            status: ListsOverviewStatus.success, lists: lists),
      ),
    );
  }

  Future<void> _onCreate(
    ListsOverviewCreateRequested event,
    Emitter<ListsOverviewState> emit,
  ) async {
    await _createList(event.name);
  }

  Future<void> _onRename(
    ListsOverviewRenameRequested event,
    Emitter<ListsOverviewState> emit,
  ) async {
    await _renameList(event.id, event.name);
  }

  Future<void> _onDelete(
    ListsOverviewDeleteRequested event,
    Emitter<ListsOverviewState> emit,
  ) async {
    await _deleteList(event.id);
  }
}
