class UserModel {
  final String id; // 🟢 NEW: The Database ID (UUID)
  final String name;
  final int studentGrade;
  final int gameLevel;
  final int xp;

  UserModel({
    required this.id, // 🟢 Required
    required this.name,
    required this.studentGrade,
    this.gameLevel = 1,
    this.xp = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id, // 🟢 Save ID
        'name': name,
        'studentGrade': studentGrade,
        'gameLevel': gameLevel,
        'xp': xp,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '', // 🟢 Load ID
      name: json['name'] ?? '',
      studentGrade: json['studentGrade'] ?? 1,
      gameLevel: json['gameLevel'] ?? 1,
      xp: json['xp'] ?? 0,
    );
  }
}
