class Usuario {
  int? id;
  String email;
  String senha;

  Usuario({
    this.id,
    required this.email,
    required this.senha,
  });

  factory Usuario.fromMap(Map<String, dynamic> json) => Usuario(
        id: json['id'],
        email: json['email'],
        senha: json['senha'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'senha': senha,
      };
}
