import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:reddit/core/constants/contants.dart';
import 'package:reddit/core/providers/store_repository_provider.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/features/community/repository/community_repository.dart';
import 'package:reddit/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

final userCommunityProvider = StreamProvider.autoDispose((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
      final communityRepository = ref.watch(communityRepositoryProvider);
      final storageRepository = ref.watch(storageRepositoryProvider);
      return CommunityController(
        communityRepository: communityRepository,
        ref: ref,
        storageRepository: storageRepository,
      );
    });

final getCommunityByNameProvider = StreamProvider.family.autoDispose((
  ref,
  String name,
) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCoomunityByName(name);
});

final searchCommunityProvider = StreamProvider.family.autoDispose((
  ref,
  String query,
) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  CommunityController({
    required CommunityRepository communityRepository,
    required Ref ref,
    required StorageRepository storageRepository,
  }) : _communityRepository = communityRepository,
       _ref = ref,
       _storageRepository = storageRepository,
       super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';
    Community community = Community(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );

    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Community Created Successfully');
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.watch(userProvider)!.uid;
    return _communityRepository.getUserCommunity(uid);
  }

  Stream<Community> getCoomunityByName(String name) {
    return _communityRepository.getCoomunityByName(name);
  }

  void editCommunity({
    required File? profileFile,
    required File? bannerFile,
    required BuildContext context,
    required Community community,
  }) async {
    state = true;
    // Community updatedCommunity = community;

    if (profileFile != null) {
      //stores the file in communnites/profile/{communityName}
      final res = await _storageRepository.storeFile(
        path: 'community/profile',
        id: community.name,
        file: profileFile,
      );
      res.fold((l) => showSnackBar(context, l.message), (r) {
        community = community.copyWith(avatar: r);
        // print('Uploaded Avatar file is ${r}');
      });
    }

    if (bannerFile != null) {
      //stores the file in communnites/banner/{communityName}
      final res = await _storageRepository.storeFile(
        path: 'community/banner',
        id: community.name,
        file: bannerFile,
      );
      res.fold((l) => showSnackBar(context, l.message), (r) {
        community = community.copyWith(banner: r);
        // print('Uploaded Banner file is ${r}');
      });
    }

    final res = await _communityRepository.editCommunity(community);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }
}
