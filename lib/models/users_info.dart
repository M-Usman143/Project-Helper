class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
  });

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      "uid": uid,
      "name": name,
      "phone": phone,
      "email": email,
    };
  }

  // Convert JSON to UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json["uid"],
      name: json["name"],
      phone: json["phone"],
      email: json["email"],
    );
  }
}
