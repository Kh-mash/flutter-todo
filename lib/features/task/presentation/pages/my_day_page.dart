import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/my_day/my_day_bloc.dart';
import '../bloc/my_day/my_day_event.dart';
import '../bloc/my_day/my_day_state.dart';
import '../widgets/task_tile.dart';
import '../widgets/quick_add_field.dart';

class MyDayPage extends StatelessWidget {
  const MyDayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'My Day',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              DateFormat('EEEE, MMMM d').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<MyDayBloc, MyDayState>(
            buildWhen: (prev, curr) =>
                prev.tasks != curr.tasks ||
                prev.showCompleted != curr.showCompleted,
            builder: (context, state) {
              final pending = state.pendingTasks.length;
              final total = state.tasks.length;
              if (total == 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Text(
                    '$pending/$total done',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<MyDayBloc, MyDayState>(
        buildWhen: (prev, curr) =>
            prev.status != curr.status ||
            prev.tasks != curr.tasks ||
            prev.showCompleted != curr.showCompleted,
        builder: (context, state) {
          if (state.status == MyDayStatus.initial) {
            context.read<MyDayBloc>().add(const MyDaySubscriptionRequested());
            return const SizedBox.shrink();
          }

          if (state.status == MyDayStatus.failure) {
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
                    Icons.wb_sunny_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks for today',
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
                          context.read<MyDayBloc>().add(
                                MyDayTaskCompletionToggled(
                                  pending[index],
                                  isCompleted: completed,
                                ),
                              );
                          HapticFeedback.lightImpact();
                        },
                        onDelete: () {
                          context
                              .read<MyDayBloc>()
                              .add(MyDayTaskDeleted(pending[index]));
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
                        context.read<MyDayBloc>().add(const MyDayShowCompletedToggled());
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
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                            context.read<MyDayBloc>().add(
                                  MyDayTaskCompletionToggled(
                                    completed[index],
                                    isCompleted: isCompleted,
                                  ),
                                );
                            HapticFeedback.lightImpact();
                          },
                          onDelete: () {
                            context
                                .read<MyDayBloc>()
                                .add(MyDayTaskDeleted(completed[index]));
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
      floatingActionButton: null,
      bottomSheet: QuickAddField(
        onSubmitted: (title) {
          context.read<MyDayBloc>().add(MyDayQuickAddSubmitted(title));
        },
      ),
    );
  }
}
