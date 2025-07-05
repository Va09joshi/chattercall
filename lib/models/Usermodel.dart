// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// lib/models/Usermodel.dart

// lib/models/Usermodel.dart

class Usermodel {
  String? uid;
  String? email;
  String? fullname;
  String? profilepic;

  Usermodel({
     this.uid,
      this.email,
      this.fullname,
     this.profilepic,
  });

  factory Usermodel.fromMap(Map<String, dynamic> map) {
    return Usermodel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      fullname: map['fullname'] ?? '',
      profilepic: map['profilepic'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullname': fullname,
      'profilepic': profilepic,
    };
  }
}



/// Save or update user data in Firestore with search keywords
Future<void> saveUser({
  required String uid,
  required String fullname,
  required String email,
  required String profilePic,
}) async {
  final keywords = {
    ...buildSearchKeywords(fullname),
    ...buildSearchKeywords(email),
  }.toList(); // removes duplicates

  await FirebaseFirestore.instance.collection('people').doc(uid).set({
    'uid': uid,
    'fullname': fullname,
    'email': email,
    'profilepic': profilePic,
    'searchKeywords': keywords,
  }, SetOptions(merge: true)); // merge to preserve existing fields
}

/// Batch patch all users with search keywords (admin function)
Future<void> patchAllUsers() async {
  final users = await FirebaseFirestore.instance.collection('people').get();

  for (final doc in users.docs) {
    final data = doc.data();
    final name  = (data['fullname'] ?? '').toString();
    final email = (data['email'] ?? '').toString();

    final keywords = {
      ...buildSearchKeywords(name),
      ...buildSearchKeywords(email),
    }.toList();

    await doc.reference.update({'searchKeywords': keywords});
  }

  print('✅ Patched ${users.docs.length} users with searchKeywords.');
}

/// Builds prefix-based search keywords (e.g. "va", "vai", "vaib", ...)
List<String> buildSearchKeywords(String text) {
  final keywords = <String>[];
  final lower = text.toLowerCase().trim();

  for (int i = 1; i <= lower.length; i++) {
    keywords.add(lower.substring(0, i));
  }

  return keywords;
}

void patchMissingTestUsers(List<String> userIds) async {
  for (String uid in userIds) {
    final doc = await FirebaseFirestore.instance.collection('people').doc(uid).get();
    if (!doc.exists) {
      await FirebaseFirestore.instance.collection('people').doc(uid).set({
        'uid': uid,
        'fullname': 'Test User $uid',
        'email': '$uid@test.com',
        'profilepic': '',
        'searchKeywords': [],
      });
      print("✅ Added dummy user: $uid");
    }
  }
}

