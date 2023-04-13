import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pagination_riverpod/http_client.dart';
import 'package:pagination_riverpod/post.dart';

part 'post_provider.freezed.dart';

@freezed
class PostState with _$PostState {
  const factory PostState({
    @Default(1) int page,
    @Default([]) List<Post> posts,
    @Default(true) bool isLoading,
    @Default(false) bool isLoadMoreError,
    @Default(false) bool isLoadMoreDone,
  }) = _PostState;

  const PostState._();
}

final postsProvider = StateNotifierProvider<PostNotifier, PostState>((ref) {
  return PostNotifier();
});

class PostNotifier extends StateNotifier<PostState> {
  PostNotifier() : super(const PostState()) {
    _initPosts();
  }

  _initPosts([int? initPage]) async {
    final page = initPage ?? state.page;
    final posts = await getPosts(page);

    if (posts.isEmpty) {
      state = state.copyWith(page: page, isLoading: false);
      return;
    }

    debugPrint('get post is ${posts.length}');
    state = state.copyWith(page: page, isLoading: false, posts: posts);
  }

  loadMorePost() async {
    StringBuffer bf = StringBuffer();

    bf.write('try to request loading ${state.isLoading} at ${state.page + 1}');
    if (state.isLoading) {
      bf.write(' fail');
      return;
    }
    bf.write(' success');
    debugPrint(bf.toString());
    state = state.copyWith(
        isLoading: true, isLoadMoreDone: false, isLoadMoreError: false);

    final posts = await getPosts(state.page + 1);

    if (posts.isEmpty) {
      // error
      state = state.copyWith(isLoadMoreError: true, isLoading: false);
      return;
    }

    debugPrint('load more ${posts.length} posts at page ${state.page + 1}');
    if (posts.isNotEmpty) {
      // if load more return a list not empty, => increment page
      state = state.copyWith(
          page: state.page + 1,
          isLoading: false,
          isLoadMoreDone: posts.isEmpty,
          posts: [...state.posts, ...posts]);
    } else {
      // not increment page
      state = state.copyWith(
        isLoading: false,
        isLoadMoreDone: posts.isEmpty,
      );
    }
  }

  Future<void> refresh() async {
    _initPosts(1);
  }
}
