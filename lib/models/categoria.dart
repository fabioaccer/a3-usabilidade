class Categoria {
  int? id;
  String nome;
  int usuarioId;
  String? cor;

  Categoria({
    this.id,
    required this.nome,
    required this.usuarioId,
    this.cor,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nome': nome,
    'usuarioId': usuarioId,
    'cor': cor,
  };

  factory Categoria.fromMap(Map<String, dynamic> json) => Categoria(
    id: json['id'],
    nome: json['nome'],
    usuarioId: json['usuarioId'],
    cor: json['cor'],
  );
}
