class School {
  final int     id;
  final String  name;
  final String? description;

  const School({
    required this.id,
    required this.name,
    this.description,
  });

  factory School.fromJson(Map<String, dynamic> json) => School(
    id:          json['id'],
    name:        json['name'],
    description: json['description'],
  );

  Map<String, dynamic> toJson() => {
    'name':        name,
    'description': description,
  };
}