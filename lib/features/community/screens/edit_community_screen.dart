import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_test.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/core/constants/contants.dart';
import 'package:reddit/core/utils.dart';
import 'package:reddit/features/community/controller/community_controller.dart';
import 'package:reddit/models/community_model.dart';
import 'package:reddit/theme/pallete.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? profileFile;

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectProfileImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        profileFile = File(res.files.first.path!);
      });
    }
  }

  void save(Community community) {
    ref
        .read(communityControllerProvider.notifier)
        .editCommunity(
          profileFile: profileFile,
          bannerFile: bannerFile,
          context: context,
          community: community,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return ref
        .watch(getCommunityByNameProvider(widget.name))
        .when(
          data: (community) => Scaffold(
            backgroundColor: Pallete.darkModeAppTheme.scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text('Edit Community'),
              centerTitle: false,
              actions: [
                TextButton(
                  onPressed: () => save(community),
                  child: Text('Save'),
                ),
              ],
            ),
            body: isLoading
                ? Loader()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: () => selectBannerImage(),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: DottedBorder(
                                    options: RectDottedBorderOptions(
                                      color: Colors.grey,
                                      strokeWidth: 1,
                                      strokeCap: StrokeCap.round,
                                      dashPattern: const [
                                        10,
                                        4,
                                      ], // dot length, space
                                    ),

                                    child: Container(
                                      width: double.infinity,
                                      height: 180,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: bannerFile != null
                                          ? Image.file(bannerFile!)
                                          : community.banner.isEmpty ||
                                                community.banner ==
                                                    Constants.bannerDefault
                                          ? Center(
                                              child: Icon(
                                                Icons.camera_alt_outlined,
                                                size: 40,
                                              ),
                                            )
                                          : Image.network(community.banner),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 20,
                                bottom: 0,
                                child: GestureDetector(
                                  onTap: () => selectProfileImage(),
                                  child: CircleAvatar(
                                    backgroundImage: profileFile != null
                                        ? FileImage(profileFile!)
                                        : NetworkImage(community.avatar),
                                    radius: 32,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => Loader(),
        );
  }
}
