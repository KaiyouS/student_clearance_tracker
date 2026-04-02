class UserProfile {
  final String  id;
  final String  firstName;
  final String? middleName;
  final String  lastName;
  final String  fullName;
  final String  accountStatus;
  final bool    needsPasswordChange;

  const UserProfile({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.fullName,
    required this.accountStatus,
    required this.needsPasswordChange,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id:                   json['id'],
      firstName:            json['first_name'],
      middleName:           json['middle_name'],
      lastName:             json['last_name'],
      fullName:             json['full_name'],
      accountStatus:        json['account_status'],
      needsPasswordChange:  json['needs_password_change'] ?? false,
    );
  }

  bool get isActive   => accountStatus == 'active';
  bool get isLocked   => accountStatus == 'locked';
  bool get isInactive => accountStatus == 'inactive';
  bool get isPending  => accountStatus == 'pending';
}