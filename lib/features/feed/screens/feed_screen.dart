import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_test.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/features/post/controllers/post_controller.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    final isGuest = !user!.isAuthenticated;
    if (!isGuest) {
      return ref
          .watch(userCommunityProvider)
          .when(
            data: (data) => ref
                .watch(userPostsProvider(data))
                .when(
                  data: (posts) {
                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (BuildContext context, int index) {
                        final post = posts[index];
                        return PostCard(post: post);
                        // return Center(child: Text('Hello'));
                      },
                    );
                  },
                  error: (error, StackTrace) {
                    print('Error is ${error.toString()}');
                    return ErrorText(error: error.toString());
                  },
                  loading: () => Loader(),
                ),
            error: (error, StackTrace) => ErrorText(error: error.toString()),
            loading: () => Loader(),
          );
    } else {
      return ref
          .watch(userCommunityProvider)
          .when(
            data: (data) => ref
                .watch(guestPostsProvider)
                .when(
                  data: (posts) {
                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (BuildContext context, int index) {
                        final post = posts[index];
                        return PostCard(post: post);
                        // return Center(child: Text('Hello'));
                      },
                    );
                  },
                  error: (error, StackTrace) {
                    print('Error is ${error.toString()}');
                    return ErrorText(error: error.toString());
                  },
                  loading: () => Loader(),
                ),
            error: (error, StackTrace) => ErrorText(error: error.toString()),
            loading: () => Loader(),
          );
    }
  }
}
