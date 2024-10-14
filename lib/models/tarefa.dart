class Tarefa {
  int? id;
  String titulo;
  String descricao;
  String data;
  String hora;
  bool realizada;
  int usuarioId;
  int categoriaId;

  Tarefa({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.hora,
    required this.realizada,
    required this.usuarioId,
    required this.categoriaId,
  });

  factory Tarefa.fromMap(Map<String, dynamic> json) => Tarefa(
        id: json['id'],
        titulo: json['titulo'],
        descricao: json['descricao'],
        data: json['data'],
        hora: json['hora'],
        realizada: json['realizada'] == 1 ? true : false,
        usuarioId: json['usuarioId'],
        categoriaId: json['categoriaId'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'data': data,
        'hora': hora,
        'realizada': realizada,
        'usuarioId': usuarioId,
        'categoriaId': categoriaId,
      };
}
