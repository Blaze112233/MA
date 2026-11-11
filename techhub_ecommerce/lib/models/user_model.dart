class UserModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'avatar_url': avatarUrl,
    };
  }
}