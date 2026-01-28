class PoliticianModel {
  final int id;
  final String name;
  final String position; // MLA or MP
  final String constituency;
  final String state;
  final String party;
  final String experience;
  final String education;
  final String imageUrl;

  PoliticianModel({
    required this.id,
    required this.name,
    required this.position,
    required this.constituency,
    required this.state,
    required this.party,
    required this.experience,
    required this.education,
    required this.imageUrl,
  });

  // Factory method to create a PoliticianModel from JSON
  factory PoliticianModel.fromJson(Map<String, dynamic> json) {
    return PoliticianModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'] ?? 'Unknown',
      position: json['position'] ?? 'MLA',
      constituency: json['constituency'] ?? 'Unknown',
      state: json['state'] ?? 'Unknown',
      party: json['party'] ?? 'Unknown',
      experience: json['experience'] ?? 'Not available',
      education: json['education'] ?? 'Not available',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
    );
  }

  // Method to convert a PoliticianModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'constituency': constituency,
      'state': state,
      'party': party,
      'experience': experience,
      'education': education,
      'imageUrl': imageUrl,
    };
  }
}
