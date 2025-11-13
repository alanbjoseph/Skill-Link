import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/search_task.dart';
import 'package:skill_link_new/features/tasks/repositories/task_repository.dart';

class SearchTasksState {
  final List<SearchTask> items;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const SearchTasksState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  SearchTasksState copyWith({
    List<SearchTask>? items,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return SearchTasksState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class SearchTasksNotifier extends Notifier<SearchTasksState> {
  static const _pageSize = 20;
  int _page = 0;

  @override
  SearchTasksState build() {
    return const SearchTasksState();
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final taskRepo = ref.read(taskRepositoryProvider);
      
      // Fetch open tasks with pagination
      final tasks = await taskRepo.fetchTasks(
        status: 'open',
        limit: _pageSize,
        offset: _page * _pageSize,
      );

      // Convert tasks to SearchTask format
      final searchTasks = tasks.map((task) {
        return SearchTask(
          id: task.id,
          title: task.title,
          description: task.description,
          budget: task.budget,
          location: task.location,
          isRemote: task.isRemote,
          category: task.category,
          posterPhotoUrl: null, // Will be populated when we add profile joining
        );
      }).toList();

      _page += 1;

      // If we got fewer items than page size, we've reached the end
      final reachedEnd = tasks.length < _pageSize;

      state = state.copyWith(
        items: [...state.items, ...searchTasks],
        isLoading: false,
        hasMore: !reachedEnd,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    // Reset pagination and state
    _page = 0;
    state = const SearchTasksState(isLoading: true, items: [], hasMore: true);
    
    // Load fresh data from the beginning
    await loadMore();
  }
}

final searchTasksProvider = NotifierProvider<SearchTasksNotifier, SearchTasksState>(
  SearchTasksNotifier.new,
);
