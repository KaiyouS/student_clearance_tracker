String profileInitials(String fullName) {
  final parts = fullName.trim().split(' ');
  if (parts.isEmpty) {
    return '?';
  }
  if (parts.length == 1) {
    return parts[0][0].toUpperCase();
  }
  return (parts.first[0] + parts.last[0]).toUpperCase();
}
