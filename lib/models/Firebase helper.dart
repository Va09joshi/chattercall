
import 'package:chat_application/models/Usermodel.dart' ;
import 'package:cloud_firestore/cloud_firestore.dart';



class FirebaseHelper {

  static Future<Usermodel?> getUserModelById(String uid) async {
    Usermodel? userModel;

    DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if(docSnap.data() != null) {
      userModel = Usermodel.fromMap(docSnap.data() as Map<String, dynamic>);
    }

    return userModel;
  }

}