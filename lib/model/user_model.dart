class User {
  final String id;
  final String name;
  final String email;
  final String profilePic;

  User({required this.id, required this.name, required this.email, required this.profilePic});

  // ✅ Add this method to parse JSON from API
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      profilePic: json['profilePic'] ?? '',
    );
  }
}
