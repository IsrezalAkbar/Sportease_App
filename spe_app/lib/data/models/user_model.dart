class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final List<String> joinedCommunities;
  final String? photoUrl;
  final String username; // Username unik untuk login (WAJIB)

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedCommunities,
    this.photoUrl,
    required this.username,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    List<String>? joinedCommunities,
    String? photoUrl,
    String? username,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      joinedCommunities: joinedCommunities ?? this.joinedCommunities,
      photoUrl: photoUrl ?? this.photoUrl,
      username: username ?? this.username,
    );
  }

  Map<String, dynamic> toMap() => {
    "uid": uid,
    "name": name,
    "email": email,
    "role": role,
    "joinedCommunities": joinedCommunities,
    "photoUrl": photoUrl,
    "username": username,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    uid: map["uid"],
    name: map["name"],
    email: map["email"],
    role: map["role"],
    joinedCommunities: List<String>.from(map["joinedCommunities"] ?? []),
    photoUrl: map["photoUrl"],
    username: map["username"],
  );
}
