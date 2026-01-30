import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_test.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/common/post_card.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/post/controllers/post_controller.dart';
import 'package:reddit/features/post/widgets/comment_card.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/responsive.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(Post post) {
    ref
        .read(postControllerProvider.notifier)
        .addComments(
          context: context,
          text: commentController.text.trim(),
          post: post,
        );
    setState(() {
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    final isGuest = !user!.isAuthenticated;

    return Scaffold(
      appBar: AppBar(),
      body: ref
          .watch(getPostByIdProvider(widget.postId))
          .when(
            data: (data) {
              return Column(
                children: [
                  PostCard(post: data),
                  Responsive(
                    child: TextField(
                      onSubmitted: (val) => isGuest ? () {} : addComment(data),
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: 'What are your thoughts',
                        filled: true,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  ref
                      .watch(getPostCommentsProvider(widget.postId))
                      .when(
                        data: (data) {
                          return Expanded(
                            child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (BuildContext context, int index) {
                                final comment = data[index];
                                return CommentCard(comment: comment);
                              },
                            ),
                          );
                        },
                        error: (error, stackTrace) =>
                            ErrorText(error: error.toString()),
                        loading: () => Loader(),
                      ),
                ],
              );
            },
            error: (error, stackTrace) => ErrorText(error: error.toString()),
            loading: () => Loader(),
          ),
    );
  }
}
