class UserModel {
  final String uid;
  final String name;
  final String email;
  final List<AddressModel> addresses;
  final String phone;
  final String role;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.addresses,
    required this.phone,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      addresses: (map['addresses'] as List<dynamic>?)
          ?.map((item) => AddressModel.fromMap(item))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'addresses': addresses.map((a) => a.toMap()).toList(),
    };
  }

  // ✅ copyWith implementation
  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? role,
    List<AddressModel>? addresses,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      addresses: addresses ?? this.addresses,
    );
  }
}
class AddressModel {
  final String address;
  final String label;
  final bool isCurrent;

  AddressModel({
    required this.address,
    required this.label,
    this.isCurrent = false,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      address: map['address'] ?? '',
      label: map['label'] ?? '',
      isCurrent: map['isCurrent'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'label': label,
      'isCurrent': isCurrent,
    };
  }
}


