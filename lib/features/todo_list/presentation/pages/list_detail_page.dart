import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../task/presentation/bloc/task_list/task_list_bloc.dart';
import '../../../task/presentation/bloc/task_list/task_list_event.dart';
import '../../../task/presentation/bloc/task_list/task_list_state.dart';
import '../../../task/presentation/widgets/quick_add_field.dart';
import '../../../task/presentation/widgets/task_tile.dart';

class ListDetailPage extends StatelessWidget {
  const ListDetailPage({super.key, required this.listId, this.listName});

  final String listId;
  final String? listName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          listName ?? 'List',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: BlocBuilder<TaskListBloc, TaskListState>(
        buildWhen: (prev, curr) =>
            prev.status != curr.status ||
            prev.tasks != curr.tasks ||
            prev.showCompleted != curr.showCompleted,
        builder: (context, state) {
          if (state.status == TaskListStatus.initial) {
            context
                .read<TaskListBloc>()
                .add(TaskListSubscriptionRequested(listId));
            return const SizedBox.shrink();
          }

          if (state.status == TaskListStatus.failure) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Something went wrong',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          final pending = state.pendingTasks;
          final completed = state.showCompleted ? state.completedTasks : [];

          if (pending.isEmpty && completed.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.list_outlined,
                    size: 64,
                    color:
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              if (pending.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.builder(
                    itemCount: pending.length,
                    itemBuilder: (context, index) {
                      return TaskTile(
                        task: pending[index],
                        onToggle: (completed) {
                          context.read<TaskListBloc>().add(
                                TaskListTaskCompletionToggled(
                                  pending[index],
                                  isCompleted: completed,
                                ),
                              );
                          HapticFeedback.lightImpact();
                        },
                        onDelete: () {
                          context
                              .read<TaskListBloc>()
                              .add(TaskListTaskDeleted(pending[index]));
                        },
                      ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(
                            begin: 0.05,
                            end: 0,
                            delay: Duration(milliseconds: 50 * index),
                            duration: 300.ms,
                          );
                    },
                  ),
                ),
              if (completed.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: GestureDetector(
                      onTap: () {
                        context
                            .read<TaskListBloc>()
                            .add(const TaskListShowCompletedToggled());
                      },
                      child: Row(
                        children: [
                          Icon(
                            state.showCompleted
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_right,
                            size: 20,
                          ),
                          Text(
                            'Completed (${completed.length})',
                            style:
                                Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state.showCompleted)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.builder(
                      itemCount: completed.length,
                      itemBuilder: (context, index) {
                        return TaskTile(
                          task: completed[index],
                          onToggle: (isCompleted) {
                            context.read<TaskListBloc>().add(
                                  TaskListTaskCompletionToggled(
                                    completed[index],
                                    isCompleted: isCompleted,
                                  ),
                                );
                            HapticFeedback.lightImpact();
                          },
                          onDelete: () {
                            context.read<TaskListBloc>().add(
                                TaskListTaskDeleted(completed[index]));
                          },
                        );
                      },
                    ),
                  ),
              ],
              const SliverPadding(padding: EdgeInsets.only(bottom: 88)),
            ],
          );
        },
      ),
      bottomSheet: QuickAddField(
        onSubmitted: (title) {
          context.read<TaskListBloc>().add(TaskListQuickAddSubmitted(title));
        },
      ),
    );
  }
}
