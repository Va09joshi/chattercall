// lib/models/Firebase helper.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Usermodel.dart';

class FirebaseHelper {
  static Future<Usermodel?> getUserModelById(String uid) async {
    try {
      final docSnap = await FirebaseFirestore.instance.collection("people").doc(uid).get();

      if (docSnap.exists && docSnap.data() != null) {
        return Usermodel.fromMap(docSnap.data()!);
      } else {
        print("⚠️ No user found with UID: $uid");
        return null;
      }
    } catch (e) {
      print("❌ Error getting user: $e");
      return null;
    }
  }
}
