class UserModel {
  final String uid;
  final String surname;
  final String firstName;
  final String studentNumber;
  final String ncstEmail;
  final String photoUrl; // URL to profile image on Firebase Storage

  const UserModel({
    required this.uid,
    required this.surname,
    required this.firstName,
    required this.studentNumber,
    required this.ncstEmail,
    required this.photoUrl,
  });

  String get fullName => '$firstName $surname';
  String get initials => '${firstName[0]}${surname[0]}'.toUpperCase();

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
        uid: m['uid'] as String? ?? '',
        surname: m['surname'] as String? ?? '',
        firstName: m['firstName'] as String? ?? '',
        studentNumber: m['studentNumber'] as String? ?? '',
        ncstEmail: m['ncstEmail'] as String? ?? '',
        photoUrl: m['photoUrl'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'surname': surname,
        'firstName': firstName,
        'studentNumber': studentNumber,
        'ncstEmail': ncstEmail,
        'photoUrl': photoUrl,
      };

  UserModel copyWith({
    String? uid,
    String? surname,
    String? firstName,
    String? studentNumber,
    String? ncstEmail,
    String? photoUrl,
  }) =>
      UserModel(
        uid: uid ?? this.uid,
        surname: surname ?? this.surname,
        firstName: firstName ?? this.firstName,
        studentNumber: studentNumber ?? this.studentNumber,
        ncstEmail: ncstEmail ?? this.ncstEmail,
        photoUrl: photoUrl ?? this.photoUrl,
      );

  @override
  String toString() => 'UserModel($fullName | $studentNumber | $ncstEmail)';
}
