import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers/firebase_providers.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/models/post_model.dart';

final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.watch(firestoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        throw "Community with the same name already exists! ";
      }
      return right(_communities.doc(community.name).set(community.toMap()));
    } on FirebaseException catch (e) {
      return left(Failure(e.message!));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid joinCommunity(String communityName, String userId) async {
    try {
      return right(
        _communities.doc(communityName).update({
          'members': FieldValue.arrayUnion([userId]),
        }),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid leaveCommunity(String communityName, String userId) async {
    try {
      return right(
        _communities.doc(communityName).update({
          'members': FieldValue.arrayRemove([userId]),
        }),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Community>> getUserCommunity(String uid) {
    return _communities.where('members', arrayContains: uid).snapshots().map((
      event,
    ) {
      List<Community> communities = [];
      for (var doc in event.docs) {
        communities.add(Community.fromMap(doc.data() as Map<String, dynamic>));
      }
      return communities;
    });
  }

  Stream<Community> getCoomunityByName(String name) {
    print('🔥 FETCHING DOC WITH ID: "$name"');
    // final normalizedName = name.trim();
    final decodedName = Uri.decodeComponent(name);

    print('Decoded Name is $decodedName');

    return _communities
        .doc(decodedName)
        .snapshots()
        .map(
          (event) => Community.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  FutureVoid editCommunity(Community community) async {
    try {
      // print('Community Data is ${community}');
      return right(_communities.doc(community.name).update(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure((e.toString())));
    }
  }

  // Stream<List<Community>> searchCommunity(String query) {
  //   return _communities
  //       .where(
  //         'name',
  //         isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
  //         isLessThan: query.isEmpty
  //             ? null
  //             : query.substring(0, query.length - 1) +
  //                   String.fromCharCode(query.codeUnitAt(query.length - 1) + 1),
  //       )
  //       .snapshots()
  //       .map((event) {
  //         List<Community> communities = [];
  //         for (var community in event.docs) {
  //           communities.add(
  //             Community.fromMap(community.data() as Map<String, dynamic>),
  //           );
  //           print('hii');
  //         }
  //         return communities;
  //       });
  // }
  Future<List<Community>> searchCommunity(String query) async {
    print('🔍 searchCommunity called with query: "$query"');

    if (query.trim().isEmpty) {
      print('⚠️ Query is empty, returning empty list');
      return [];
    }

    String searchQuery = query.trim();
    print('🔎 Searching Firestore for: "$searchQuery"');

    try {
      // Get snapshot once (not a stream)
      final snapshot = await _communities.get();

      print('✅ Firestore returned ${snapshot.docs.length} total documents');

      List<Community> allCommunities = snapshot.docs
          .map((doc) => Community.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter client-side (case-sensitive)
      List<Community> filtered = allCommunities
          .where((community) => community.name.startsWith(searchQuery))
          .toList();

      print(
        '📊 After filtering: ${filtered.length} communities match "$searchQuery"',
      );

      return filtered;
    } catch (error) {
      print('❌ Firestore error: $error');
      rethrow;
    }
  }

  FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      final decodedName = Uri.decodeComponent(communityName);

      // print('Community Data is ${community}');
      return right(_communities.doc(decodedName).update({'mods': uids}));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure((e.toString())));
    }
  }

  Stream<List<Post>> getCommunityPosts(String name) {
    final decodedName = Uri.decodeComponent(name);

    return _posts
        .where('communityName', isEqualTo: decodedName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);
  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);
}
