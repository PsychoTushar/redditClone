// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:reddit/core/common/error_test.dart';
// // import 'package:reddit/core/common/loader.dart';
// // import 'package:reddit/features/auth/controller/auth_controller.dart';
// // import 'package:reddit/features/auth/screens/login_screen.dart';
// // import 'package:reddit/firebase_options.dart';
// // import 'package:reddit/models/user_model.dart';
// // import 'package:reddit/router.dart';
// // import 'package:reddit/theme/pallete.dart';
// // import 'package:routemaster/routemaster.dart';

// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
// //   runApp(ProviderScope(child: const MyApp()));
// // }

// // class MyApp extends ConsumerStatefulWidget {
// //   const MyApp({super.key});

// //   @override
// //   ConsumerState<MyApp> createState() => _MyAppState();
// // }

// // class _MyAppState extends ConsumerState<MyApp> {
// //   UserModel? userModel;

// //   void getData(WidgetRef ref, User data) async {
// //     userModel = await ref
// //         .watch(authControllerProvider.notifier)
// //         .getUserData(data.uid)
// //         .first;
// //     ref.read(userProvider.notifier).update((state) => userModel);
// //     setState(() {});
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return ref
// //         .watch(authStateChangeProvider)
// //         .when(
// //           data: (data) => MaterialApp.router(
// //             title: 'Flutter Demo',
// //             debugShowCheckedModeBanner: false,
// //             theme: Pallete.darkModeAppTheme,
// //             routerDelegate: RoutemasterDelegate(
// //               routesBuilder: (context) {
// //                 if (data != null) {
// //                   getData(ref, data);
// //                   if (userModel != null) {
// //                     return loggedInRoute;
// //                   }
// //                 }
// //                 {
// //                   return loggedOutRoute;
// //                 }
// //               },
// //             ),
// //             routeInformationParser: RoutemasterParser(),
// //             // home: const LoginScreen(),
// //           ),
// //           error: (error, StackTrace) => ErrorText(error: error.toString()),
// //           loading: () => Loader(),
// //         );
// //   }
// // }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:reddit/core/common/error_test.dart';
// import 'package:reddit/core/common/loader.dart';
// import 'package:reddit/features/auth/controller/auth_controller.dart';
// import 'package:reddit/firebase_options.dart';
// import 'package:reddit/router.dart';
// import 'package:reddit/theme/pallete.dart';
// import 'package:routemaster/routemaster.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   runApp(const ProviderScope(child: MyApp()));
// }

// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return ref
//         .watch(authStateChangeProvider)
//         .when(
//           data: (user) {
//             // User is logged in
//             if (user != null) {
//               return ref
//                   .watch(getUserDataProvider(user.uid))
//                   .when(
//                     data: (userModel) {
//                       // Update userProvider with fetched user data
//                       Future.microtask(() {
//                         ref.read(userProvider.notifier).state = userModel;
//                       });

//                       return MaterialApp.router(
//                         title: 'Reddit Clone',
//                         debugShowCheckedModeBanner: false,
//                         theme: Pallete.darkModeAppTheme,
//                         routerDelegate: RoutemasterDelegate(
//                           routesBuilder: (context) => loggedInRoute,
//                         ),
//                         routeInformationParser: const RoutemasterParser(),
//                       );
//                     },
//                     loading: () => const MaterialApp(
//                       debugShowCheckedModeBanner: false,
//                       home: Scaffold(body: Loader()),
//                     ),
//                     error: (error, stack) => MaterialApp(
//                       debugShowCheckedModeBanner: false,
//                       home: Scaffold(body: ErrorText(error: error.toString())),
//                     ),
//                   );
//             }

//             // User is not logged in
//             return MaterialApp.router(
//               title: 'Reddit Clone',
//               debugShowCheckedModeBanner: false,
//               theme: Pallete.darkModeAppTheme,
//               routerDelegate: RoutemasterDelegate(
//                 routesBuilder: (context) => loggedOutRoute,
//               ),
//               routeInformationParser: const RoutemasterParser(),
//             );
//           },
//           loading: () => Loader(),
//           error: (error, stack) => MaterialApp(
//             debugShowCheckedModeBanner: false,
//             home: Scaffold(body: ErrorText(error: error.toString())),
//           ),
//         );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit/core/common/error_test.dart';
import 'package:reddit/core/common/loader.dart';
import 'package:reddit/features/auth/controller/auth_controller.dart';
import 'package:reddit/firebase_options.dart';
import 'package:reddit/router.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // ✅ Listen to auth changes and update userProvider
    ref.listenManual(authStateChangeProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          // Fetch and update user data when auth state changes
          ref.listen(getUserDataProvider(user.uid), (previous, next) {
            next.whenData((userModel) {
              ref.read(userProvider.notifier).state = userModel;
            });
          });
        } else {
          // Clear userProvider when logged out
          ref.read(userProvider.notifier).state = null;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(authStateChangeProvider)
        .when(
          data: (user) {
            if (user != null) {
              return ref
                  .watch(getUserDataProvider(user.uid))
                  .when(
                    data: (userModel) {
                      // ✅ Always keep userProvider in sync
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (ref.read(userProvider)?.uid != userModel.uid) {
                          ref.read(userProvider.notifier).state = userModel;
                        }
                      });

                      return MaterialApp.router(
                        title: 'Reddit Clone',
                        debugShowCheckedModeBanner: false,
                        theme: ref.watch(themeNotifierProvider),
                        routerDelegate: RoutemasterDelegate(
                          routesBuilder: (context) => loggedInRoute,
                        ),
                        routeInformationParser: const RoutemasterParser(),
                      );
                    },
                    loading: () => const MaterialApp(
                      debugShowCheckedModeBanner: false,
                      home: Scaffold(body: Loader()),
                    ),
                    error: (error, stack) => MaterialApp(
                      debugShowCheckedModeBanner: false,
                      home: Scaffold(body: ErrorText(error: error.toString())),
                    ),
                  );
            }

            return MaterialApp.router(
              title: 'Reddit Clone',
              debugShowCheckedModeBanner: false,
              theme: Pallete.darkModeAppTheme,
              routerDelegate: RoutemasterDelegate(
                routesBuilder: (context) => loggedOutRoute,
              ),
              routeInformationParser: const RoutemasterParser(),
            );
          },
          loading: () => Loader(),
          error: (error, stack) => MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: ErrorText(error: error.toString())),
          ),
        );
  }
}
