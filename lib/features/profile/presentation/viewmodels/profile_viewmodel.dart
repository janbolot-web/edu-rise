import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Stream provider that exposes the current [User] or null if signed out.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Simple helper provider that allows signing out.
final authActionsProvider = Provider<AuthActions>((ref) => AuthActions());

class AuthActions {
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  /// Pick image from gallery and upload to Firebase Storage, then update user's photoURL.
  Future<void> pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No signed in user');

    final storageRef = FirebaseStorage.instance.ref().child('avatars/${user.uid}.jpg');
    try {
      // debug info
      debugPrint('Uploading avatar for ${user.uid} to ${storageRef.fullPath} in bucket ${storageRef.bucket}');
      final uploadTask = storageRef.putFile(File(file.path));
      // await the task and get snapshot
      final snapshot = await uploadTask;
      debugPrint('UploadTask state: ${snapshot.state}');
      if (snapshot.state != TaskState.success) {
        throw FirebaseException(plugin: 'firebase_storage', message: 'Upload did not complete successfully', code: 'upload-failed');
      }

      // Use the snapshot's ref to get URL (safer than calling storageRef.getDownloadURL() immediately)
      final url = await snapshot.ref.getDownloadURL();
      debugPrint('Uploaded avatar URL: $url');
      await user.updatePhotoURL(url);
      await user.reload();
      // Debug: list contents of avatars/ to verify object presence
      try {
        final parent = storageRef.parent; // should be 'avatars'
        if (parent != null) {
          final listResult = await parent.listAll();
          final names = listResult.items.map((i) => i.fullPath).toList();
          debugPrint('Avatars folder contents: $names');
        }
      } catch (e) {
        debugPrint('Listing avatars failed: $e');
      }
    } on FirebaseException catch (e) {
      // map common storage errors to more friendly message
      String msg = e.message ?? 'Storage error';
      if (e.code == 'object-not-found') {
        msg = 'No uploaded file found at storage reference (${storageRef.fullPath}). Check bucket name and rules.';
      } else if (e.code == 'permission-denied') {
        msg = 'Upload blocked by security rules. Ensure authenticated users can write to avatars/';
      }
      throw Exception('Avatar upload failed: [${e.code}] $msg');
    }
  }
}
