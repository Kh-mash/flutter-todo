import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/injector.dart';
import '../../features/task/presentation/bloc/my_day/my_day_bloc.dart';
import '../../features/task/presentation/bloc/task_list/task_list_bloc.dart';
import '../../features/task/presentation/pages/my_day_page.dart';
import '../../features/todo_list/presentation/bloc/lists_overview/lists_overview_bloc.dart';
import '../../features/todo_list/presentation/pages/list_detail_page.dart';
import '../../features/todo_list/presentation/pages/lists_overview_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/my-day',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => _AdaptiveScaffold(
        navigationShell: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/my-day',
              builder: (context, state) => BlocProvider(
                create: (_) => getIt<MyDayBloc>(),
                child: const MyDayPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/lists',
              builder: (context, state) => BlocProvider(
                create: (_) => getIt<ListsOverviewBloc>(),
                child: const ListsOverviewPage(),
              ),
              routes: [
                GoRoute(
                  path: ':listId',
                  builder: (context, state) => BlocProvider(
                    create: (_) => getIt<TaskListBloc>(),
                    child: ListDetailPage(
                      listId: state.pathParameters['listId']!,
                      listName: state.extra as String?,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class _AdaptiveScaffold extends StatelessWidget {
  const _AdaptiveScaffold({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 720;

    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.wb_sunny_outlined),
        selectedIcon: const Icon(Icons.wb_sunny),
        label: 'My Day',
      ),
      NavigationDestination(
        icon: const Icon(Icons.list_outlined),
        selectedIcon: const Icon(Icons.list),
        label: 'Lists',
      ),
    ];

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.wb_sunny_outlined),
                  selectedIcon: const Icon(Icons.wb_sunny),
                  label: const Text('My Day'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.list_outlined),
                  selectedIcon: const Icon(Icons.list),
                  label: const Text('Lists'),
                ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: destinations,
      ),
    );
  }
}
