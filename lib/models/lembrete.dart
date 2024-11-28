class Lembrete {
  int? id;
  String titulo;
  String descricao;
  String data;
  String hora;
  int usuarioId;
  int? tarefaId;

  Lembrete({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.data,
    required this.hora,
    required this.usuarioId,
    this.tarefaId,
  });

  factory Lembrete.fromMap(Map<String, dynamic> json) => Lembrete(
        id: json['id'],
        titulo: json['titulo'],
        descricao: json['descricao'],
        data: json['data'],
        hora: json['hora'],
        usuarioId: json['usuarioId'],
        tarefaId: json['tarefaId'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'data': data,
        'hora': hora,
        'usuarioId': usuarioId,
        'tarefaId': tarefaId,
      };

  bool isExpirado() {
    final partsData = data.split('/');
    final partsHora = hora.split(':');
    
    final dataHoraLembrete = DateTime(
      int.parse(partsData[2]), // ano
      int.parse(partsData[1]), // mês
      int.parse(partsData[0]), // dia
      int.parse(partsHora[0]), // hora
      int.parse(partsHora[1]), // minuto
    );

    return DateTime.now().isAfter(dataHoraLembrete);
  }
}
