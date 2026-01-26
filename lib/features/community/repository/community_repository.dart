import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit/core/constants/firebase_constants.dart';
import 'package:reddit/core/failure.dart';
import 'package:reddit/core/providers/firebase_providers.dart';
import 'package:reddit/core/type_defs.dart';
import 'package:reddit/models/community_model.dart';

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
    return _communities
        .doc(name)
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
  //   print('Search query is $query');
  //   return _communities
  //       .where(
  //         'name',
  //         isEqualTo: query,
  //         // isGreaterThanOrEqualTo: query.isEmpty ? null : query,
  //         // isLessThan: query.isEmpty
  //         //     ? null
  //         //     : query.substring(0, query.length - 1) +
  //         //           String.fromCharCode(query.codeUnitAt(query.length - 1) + 1),
  //       )
  //       .snapshots()
  //       .map((event) {
  //         List<Community> communities = [];
  //         for (var community in event.docs) {
  //           communities.add(
  //             Community.fromMap(community.data() as Map<String, dynamic>),
  //           );
  //         }
  //         print('Fetched Communites are ${communities.length}');
  //         return communities;
  //       });
  // }

  // Stream<List<Community>> searchCommunity(String query) {
  //   print('Search query is "$query"');

  //   if (query.isEmpty) {
  //     return _communities.snapshots().map((event) {
  //       print('Fetched Communities are ${event.docs.length}');
  //       return event.docs
  //           .map((doc) => Community.fromMap(doc.data() as Map<String, dynamic>))
  //           .toList();
  //     });
  //   }

  //   return _communities
  //       .where('name', isGreaterThanOrEqualTo: query)
  //       .where('name', isLessThanOrEqualTo: '$query\uf8ff')
  //       .snapshots()
  //       .map((event) {
  //         print('Fetched Communities are ${event.docs.length}');
  //         return event.docs
  //             .map(
  //               (doc) => Community.fromMap(doc.data() as Map<String, dynamic>),
  //             )
  //             .toList();
  //       });
  // }

  Stream<List<Community>> searchCommunity(String query) {
  print('Search query is "$query"');
final q = query.toLowerCase();
  try {
    if (query.isEmpty) {
      return _communities.snapshots().map((event) {
        print('Fetched Communities are ${event.docs.length}');
        return event.docs
            .map(
              (doc) => Community.fromMap(
                doc.data() as Map<String, dynamic>,
              ),
            )
            .toList();
      });
    }

    return _communities
        .where('name', isGreaterThanOrEqualTo: q)
        .where('name', isLessThanOrEqualTo: '$q\uf8ff')
        .snapshots()
        .map((event) {
          print('Fetched Communities are ${event.docs.length}');
          return event.docs
              .map(
                (doc) => Community.fromMap(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();
        });
  } catch (e, st) {
    print('🔥 Error in searchCommunity: $e');
    print(st);

    // Return a safe empty stream so UI doesn’t crash
    return Stream.value([]);
  }
}


  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.communitiesCollection);
}
