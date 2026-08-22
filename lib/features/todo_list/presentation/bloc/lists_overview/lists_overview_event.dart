import 'package:equatable/equatable.dart';

sealed class ListsOverviewEvent extends Equatable {
  const ListsOverviewEvent();
  @override
  List<Object?> get props => [];
}

class ListsOverviewSubscriptionRequested extends ListsOverviewEvent {
  const ListsOverviewSubscriptionRequested();
}

class ListsOverviewCreateRequested extends ListsOverviewEvent {
  const ListsOverviewCreateRequested(this.name);
  final String name;
  @override
  List<Object?> get props => [name];
}

class ListsOverviewRenameRequested extends ListsOverviewEvent {
  const ListsOverviewRenameRequested(this.id, this.name);
  final String id;
  final String name;
  @override
  List<Object?> get props => [id, name];
}

class ListsOverviewDeleteRequested extends ListsOverviewEvent {
  const ListsOverviewDeleteRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
