class Usermodel{
  String? uid;
  String? email;
  String? fullname;
  String? profilepic;


  Usermodel({this.uid,this.email,this.fullname,this.profilepic});

  Usermodel.fromMap(Map<String,dynamic> map){
       uid : map['uid'];
       fullname : map['fullname'];
       email : map['email'];
       profilepic : map['profilepic'];

  }

  Map<String,dynamic> Tomap(){
    return {
      "uid" : uid,
      "fullname" : fullname,
      "email" : email,
      "profilepic" : profilepic
    };
  }
}