import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reddit/core/providers/store_repository_provider.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/user_profile/repository/user_profile_repository.dart';
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
  }) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;
    if (profileFile != null) {
      //stores the file in communnites/profile/{communityName}
      final res = await _storageRepository.storeFile(
        path: 'users/profile',
        id: user.uid,
        file: profileFile,
      );
      res.fold((l) => showSnackBar(context, l.message), (r) {
        user = user.copyWith(profilePic: r);
        // print('Uploaded Avatar file is ${r}');
      });
    }

    if (bannerFile != null) {
      //stores the file in communnites/banner/{communityName}
      final res = await _storageRepository.storeFile(
        path: 'users/banner',
        id: user.uid,
        file: bannerFile,
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
}
