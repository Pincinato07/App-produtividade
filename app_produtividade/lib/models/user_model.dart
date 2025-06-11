class UserModel {
  final String id;
  final String name;
  final String email;
  final double? weight;
  final double? height;
  final String authProvider;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.weight,
    this.height,
    required this.authProvider,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'weight': weight,
      'height': height,
      'authProvider': authProvider,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      authProvider: json['authProvider'] as String,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    double? weight,
    double? height,
    String? authProvider,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      authProvider: authProvider ?? this.authProvider,
    );
  }
}
