class Office {
  final int     id;
  final String  name;
  final String? description;

  const Office({
    required this.id,
    required this.name,
    this.description,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      id:          json['id'],
      name:        json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name':        name,
    'description': description,
  };
}