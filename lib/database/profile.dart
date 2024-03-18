class Profile {
  final int? id; // Making id nullable

  final String name;
  final String imagePath;

  Profile({
    this.id, // Making id optional
    required this.name,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Using nullable id
      'name': name,
      'imagePath': imagePath,
    };
  }
}
