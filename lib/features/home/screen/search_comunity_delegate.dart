import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_test.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class SearchCommunityDelegate extends SearchDelegate {
  final WidgetRef ref;
  Future<List<Community>>? _searchFuture;
  String? _lastQuery;
  SearchCommunityDelegate(this.ref);
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
          _searchFuture = null; // Reset cache
          _lastQuery = null;
        },
        icon: Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text(
          'Enter a community name to search',
          style: TextStyle(fontSize: 16),
        ),
      );
    }
    print('Building results for query: ${query.trim()}'); // Debug print
    ref.invalidate(searchCommunityProvider(query.trim()));
    // Only create a new future if the query has changed
    if (_lastQuery != query.trim()) {
      print('Query changed, creating new future');
      _lastQuery = query.trim();
      _searchFuture = ref
          .read(communityControllerProvider.notifier)
          .searchCommunity(query.trim());
    }
    return FutureBuilder<List<Community>>(
      future: _searchFuture,
      builder: (context, snapshot) {
        print('FutureBuilder state: ${snapshot.connectionState}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Loading search results...');
          return const Loader();
        }

        if (snapshot.hasError) {
          print('Error in search: ${snapshot.error}');
          return ErrorText(error: snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('No communities found');
          return const Center(
            child: Text('No communities found', style: TextStyle(fontSize: 16)),
          );
        }

        final communities = snapshot.data!;
        print('✨ Displaying ${communities.length} communities');

        return ListView.builder(
          itemCount: communities.length,
          itemBuilder: (BuildContext context, int index) {
            final community = communities[index];
            return ListTile(
              onTap: () {
                close(context, null);
                navigateToCommunity(context, community.name);
              },
              leading: CircleAvatar(
                backgroundImage: NetworkImage(community.avatar),
              ),
              title: Text('r/${community.name}'),
            );
          },
        );
      },
    );

    // return ref
    //     .watch(searchCommunityProvider(query.trim()))
    //     .when(
    //       data: (communities) {
    //         print('Got ${communities.length} communities'); // Debug print

    //         if (communities.isEmpty) {
    //           return const Center(
    //             child: Text(
    //               'No communities found',
    //               style: TextStyle(fontSize: 16),
    //             ),
    //           );
    //         }

    //         return ListView.builder(
    //           itemCount: communities.length,
    //           itemBuilder: (BuildContext context, int index) {
    //             final community = communities[index];
    //             return ListTile(
    //               onTap: () {
    //                 close(context, null); // Close search when navigating
    //                 navigateToCommunity(context, community.name);
    //               },
    //               leading: CircleAvatar(
    //                 backgroundImage: NetworkImage(community.avatar),
    //               ),
    //               title: Text('r/${community.name}'),
    //             );
    //           },
    //         );
    //       },
    //       error: (error, stackTrace) => ErrorText(error: error.toString()),
    //       loading: () => const Loader(),
    //     );
    // return ref
    //     .watch(searchCommunityProvider(query))
    //     .when(
    //       data: (communities) => ListView.builder(
    //         itemCount: communities.length,
    //         itemBuilder: (BuildContext context, int index) {
    //           final community = communities[index];
    //           return ListTile(
    //             onTap: () => navigateToCommunity(context, community.name),
    //             leading: CircleAvatar(
    //               backgroundImage: NetworkImage(community.avatar),
    //             ),
    //             title: Text('r/${community.name}'),
    //           );
    //         },
    //       ),
    //       error: (error, StackTrace) => ErrorText(error: error.toString()),
    //       loading: () => Loader(),
    //     );
    // return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SizedBox();
    // return ref
    //     .watch(searchCommunityProvider(query))
    //     .when(
    //       data: (communities) => ListView.builder(
    //         itemCount: communities.length,
    //         itemBuilder: (BuildContext context, int index) {
    //           final community = communities[index];
    //           return ListTile(
    //             onTap: () => navigateToCommunity(context, community.name),
    //             leading: CircleAvatar(
    //               backgroundImage: NetworkImage(community.avatar),
    //             ),
    //             title: Text('r/${community.name}'),
    //           );
    //         },
    //       ),
    //       error: (error, StackTrace) => ErrorText(error: error.toString()),
    //       loading: () => Loader(),
    //     );
  }

  void navigateToCommunity(BuildContext context, String communityName) {
    Routemaster.of(context).push('/r/$communityName');
  }
}
