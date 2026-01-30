import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reddit/core/enums/enums.dart';
import 'package:reddit/core/providers/storage_repository_provider.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/user_profile/repository/user_profile_repository.dart';
import 'package:reddit/models/post_model.dart';
import 'package:reddit/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
      final userProfileRepository = ref.watch(userProfileRepositoryProvider);
      final storageRepository = ref.watch(storageRepositoryProvider);
      return UserProfileController(
        userProfileRepository: userProfileRepository,
        ref: ref,
        storageRepository: storageRepository,
      );
    });

final getUserPostsProvider = StreamProvider.family.autoDispose((
  ref,
  String uid,
) {
  return ref.read(userProfileControllerProvider.notifier).getUserPosts(uid);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  UserProfileController({
    required UserProfileRepository userProfileRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  }) : _userProfileRepository = userProfileRepository,
       _ref = ref,
       _storageRepository = storageRepository,
       super(false);

  void editUserProfile({
    required File? profileFile,
    required File? bannerFile,
    required BuildContext context,
    required String name,
    final Uint8List? profileWebFile,
    final Uint8List? bannerWebFile,
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;
    if (profileFile != null || profileWebFile != null) {
      //stores the file in communnites/profile/{communityName}
      final res = await _storageRepository.storeFile(
        path: 'users/profile',
        id: user.uid,
        file: profileFile,
        webFile: profileWebFile,
      );
      res.fold((l) => showSnackBar(context, l.message), (r) {
        user = user.copyWith(profilePic: r);
        // print('Uploaded Avatar file is ${r}');
      });
    }

    if (bannerFile != null || bannerWebFile != null) {
      //stores the file in communnites/banner/{communityName}
      final res = await _storageRepository.storeFile(
        path: 'users/banner',
        id: user.uid,
        file: bannerFile,
        webFile: bannerWebFile,
      );
      res.fold((l) => showSnackBar(context, l.message), (r) {
        user = user.copyWith(banner: r);
        // print('Uploaded Banner file is ${r}');
      });
    }
    user = user.copyWith(name: name);
    final res = await _userProfileRepository.editProfile(user);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref.read(userProvider.notifier).update((state) => user);
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _userProfileRepository.getUserPosts(uid);
  }

  void updateUserKarma(UserKarma karma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + karma.karma);
    final res = await _userProfileRepository.updateUserKarma(user);
    res.fold(
      (l) => null,
      (r) => _ref.read(userProvider.notifier).update((state) => user),
    );
  }
}
