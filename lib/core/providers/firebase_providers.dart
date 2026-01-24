import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final authProvider = Provider((ref) => FirebaseAuth.instance);
final storageProvider = Provider((ref) => FirebaseStorage.instance);

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  final googleSignIn = GoogleSignIn.instance;

  // MUST be called exactly once
  googleSignIn.initialize(
    serverClientId:
        '355480003866-09637q7r3tbtgq3b4chfulu448fi4snd.apps.googleusercontent.com',
  );

  return googleSignIn;
});
