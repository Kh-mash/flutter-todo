import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/todo_list.dart';
import '../../../settings/presentation/widgets/theme_toggle_button.dart';
import '../bloc/lists_overview/lists_overview_bloc.dart';
import '../bloc/lists_overview/lists_overview_event.dart';
import '../bloc/lists_overview/lists_overview_state.dart';

class ListsOverviewPage extends StatelessWidget {
  const ListsOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lists',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: const [ThemeToggleButton()],
      ),
      body: BlocBuilder<ListsOverviewBloc, ListsOverviewState>(
        buildWhen: (prev, curr) =>
            prev.status != curr.status || prev.lists != curr.lists,
        builder: (context, state) {
          if (state.status == ListsOverviewStatus.initial) {
            context.read<ListsOverviewBloc>().add(
                  const ListsOverviewSubscriptionRequested(),
                );
            return const SizedBox.shrink();
          }

          if (state.status == ListsOverviewStatus.failure) {
            return Center(child: Text(state.errorMessage ?? 'Error'));
          }

          if (state.lists.isEmpty) {
            return const Center(child: Text('No lists yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.lists.length,
            itemBuilder: (context, index) {
              final summary = state.lists[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.list),
                  title: Text(summary.list.name),
                  subtitle: Text('${summary.openCount} tasks'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push(
                      '/lists/${summary.list.id}',
                      extra: summary.list.name,
                    );
                  },
                  onLongPress: () => _showRenameDialog(context, summary),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New List'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'List name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<ListsOverviewBloc>().add(
                      ListsOverviewCreateRequested(controller.text.trim()),
                    );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context, ListSummary summary) {
    final controller = TextEditingController(text: summary.list.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename List'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<ListsOverviewBloc>().add(
                      ListsOverviewRenameRequested(
                        summary.list.id,
                        controller.text.trim(),
                      ),
                    );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}
