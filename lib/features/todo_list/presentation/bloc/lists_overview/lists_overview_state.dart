import 'package:equatable/equatable.dart';

import '../../../domain/entities/todo_list.dart';

enum ListsOverviewStatus { initial, loading, success, failure }

class ListsOverviewState extends Equatable {
  const ListsOverviewState({
    this.status = ListsOverviewStatus.initial,
    this.lists = const [],
    this.errorMessage,
  });

  final ListsOverviewStatus status;
  final List<ListSummary> lists;
  final String? errorMessage;

  ListsOverviewState copyWith({
    ListsOverviewStatus? status,
    List<ListSummary>? lists,
    String? errorMessage,
  }) {
    return ListsOverviewState(
      status: status ?? this.status,
      lists: lists ?? this.lists,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, lists, errorMessage];
}
