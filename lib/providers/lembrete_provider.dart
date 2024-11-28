import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/lembrete.dart';
import '../db/lembrete_db.dart';

class LembreteProvider with ChangeNotifier {
  List<Lembrete> _lembretes = [];
  final LembreteDb _lembreteDb = LembreteDb();

  List<Lembrete> get lembretes => [..._lembretes];

  Future<void> carregaLembretes(int usuarioId) async {
    _lembretes = await _lembreteDb.listarLembretes(usuarioId);
    notifyListeners();
  }

  Future<void> criaLembrete(Lembrete lembrete) async {
    try {
      final id = await _lembreteDb.criarLembrete(lembrete);
      
      final novoLembrete = Lembrete(
        id: id,
        titulo: lembrete.titulo,
        descricao: lembrete.descricao,
        data: lembrete.data,
        hora: lembrete.hora,
        usuarioId: lembrete.usuarioId,
        tarefaId: lembrete.tarefaId,
      );

      _lembretes.add(novoLembrete);
      notifyListeners();

      await _agendarNotificacao(novoLembrete);
    } catch (e) {
      print('Erro ao criar lembrete: $e');
      rethrow;
    }
  }

  Future<void> editaLembrete(Lembrete lembrete) async {
    try {
      final index = _lembretes.indexWhere((l) => l.id == lembrete.id);
      if (index >= 0) {
        await _lembreteDb.editarLembrete(lembrete);
        _lembretes[index] = lembrete;
        notifyListeners();

        // Cancela a notificação antiga e agenda uma nova
        await AwesomeNotifications().cancel(lembrete.id!);
        await _agendarNotificacao(lembrete);
      }
    } catch (e) {
      print('Erro ao editar lembrete: $e');
      rethrow;
    }
  }

  Future<void> deletaLembrete(int id) async {
    try {
      final existingLembreteIndex = _lembretes.indexWhere((l) => l.id == id);
      if (existingLembreteIndex >= 0) {
        await _lembreteDb.excluirLembrete(id);
        _lembretes.removeAt(existingLembreteIndex);
        await AwesomeNotifications().cancel(id);
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao deletar lembrete: $e');
      rethrow;
    }
  }

  Future<void> listaLembretesPorTarefa(int usuarioId, int tarefaId) async {
    _lembretes = await LembreteDb().listarLembretes(usuarioId);
    _lembretes = _lembretes.where((lembrete) => lembrete.tarefaId == tarefaId).toList();
    notifyListeners();
  }

  Future<void> _agendarNotificacao(Lembrete lembrete) async {
    try {
      if (lembrete.id == null) {
        print('Erro: ID do lembrete é nulo');
        return;
      }

      // Converte a data e hora do lembrete para DateTime
      final partsData = lembrete.data.split('/');
      final partsHora = lembrete.hora.split(':');
      
      final scheduledDate = DateTime(
        int.parse(partsData[2]), // ano
        int.parse(partsData[1]), // mês
        int.parse(partsData[0]), // dia
        int.parse(partsHora[0]), // hora
        int.parse(partsHora[1]), // minuto
        0, // segundo
        0, // milissegundo
      );

      // Verifica se a data é no futuro
      final now = DateTime.now();
      final nowWithoutSeconds = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute,
        0,
        0,
      );

      if (scheduledDate.isBefore(nowWithoutSeconds)) {
        print('Aviso: Data do lembrete (${scheduledDate.toString()}) está no passado, notificação não será agendada');
        return;
      }

      print('Agendando notificação para: ${scheduledDate.toString()}');
      
      // Cria a notificação
      final success = await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: lembrete.id!,
          channelKey: 'basic_channel',
          title: '🔔 ${lembrete.titulo}',
          body: lembrete.descricao,
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
          displayOnForeground: true,
          displayOnBackground: true,
        ),
        schedule: NotificationCalendar(
          year: scheduledDate.year,
          month: scheduledDate.month,
          day: scheduledDate.day,
          hour: scheduledDate.hour,
          minute: scheduledDate.minute,
          second: 0,
          millisecond: 0,
          allowWhileIdle: true,
          preciseAlarm: true,
          timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
          repeats: false,
        ),
      );

      if (success) {
        print('Notificação agendada com sucesso para: ${scheduledDate.toString()}');
        
        // Lista todas as notificações agendadas para debug
        final schedules = await AwesomeNotifications().listScheduledNotifications();
        print('Notificações agendadas: ${schedules.length}');
        for (var schedule in schedules) {
          print('ID: ${schedule.content?.id}, Título: ${schedule.content?.title}, Agendada para: ${schedule.schedule?.toMap()}');
        }
      } else {
        print('Erro ao agendar notificação');
      }
    } catch (e) {
      print('Erro ao agendar notificação: $e');
      rethrow;
    }
  }
}
