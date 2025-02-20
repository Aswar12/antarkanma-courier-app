class Courier {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String profilePhotoUrl;

  Courier({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.profilePhotoUrl,
  });

  factory Courier.fromJson(Map<String, dynamic> json) {
    return Courier(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      profilePhotoUrl: json['profile_photo_url'],
    );
  }
}
