class Customer {
  final int id;
  final String name;
  final String email;
  final String phone;

  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
      );
}
