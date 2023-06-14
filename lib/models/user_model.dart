import 'dart:convert';

class User {
  String uid;
  String name;
  String username;
  String college;
  String course;
  String studno;
  String email;
  String password;
  // List<String> preexistingillness;

  String status;
  // List<String> entries;  // refernece?

  int userType;

  String empno;
  String position;
  String homeunit;

  User({
    required this.uid,
    required this.name,
    required this.username,
    required this.college,
    required this.course,
    required this.studno,
    required this.email,
    required this.password,
    // required this.preexistingillness,
    required this.status,
    // required this.entries,
    required this.userType,
    required this.empno,
    required this.position,
    required this.homeunit,
  });

  // Factory constructor to instantiate object from json format
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      name: json['name'],
      username: json['username'],
      college: json['college'],
      course: json['course'],
      studno: json['studno'],
      email: json['email'],
      password: json['password'],
      // preexistingillness: json['preexistingillness'],
      status: json['status'],
      // entries: json['entries'],
      userType: json['userType'],
      empno: json['empno'],
      position: json['position'],
      homeunit: json['homeunit'],
    );
  }

  static List<User> fromJsonArray(String jsonData) {
    final Iterable<dynamic> data = jsonDecode(jsonData);
    return data.map<User>((dynamic d) => User.fromJson(d)).toList();
  }

  Map<String, dynamic> toJson(User user) {
    return {
      'uid': user.uid,
      'lastName': user.name,
      'username': user.username,
      'college': user.college,
      'course': user.course,
      'studno': user.studno,
      'email': user.email,
      'password': user.password,
      // 'preexistingillness':user.preexistingillness,
      'status': user.status,
      // 'entries':user.entries,
      'userType': user.userType,
      'empno': user.empno,
      'position': user.position,
      'homeunit': user.homeunit,
    };
  }
}
