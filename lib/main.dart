// Imports do Flutter
import 'package:flutter/material.dart';

// Imports de pacotes externos
import 'package:provider/provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Imports locais do app
import 'providers/auth_provider.dart';
import 'providers/categoria_provider.dart';
import 'providers/tarefa_provider.dart';
import 'providers/lembrete_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_screen.dart';

// Métodos estáticos para lidar com as notificações
@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  debugPrint('Notificação clicada: ${receivedAction.title}');
}

@pragma('vm:entry-point')
Future<void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
  debugPrint('Notificação criada: ${receivedNotification.title}');
}

@pragma('vm:entry-point')
Future<void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
  debugPrint('Notificação mostrada: ${receivedNotification.title}');
}

@pragma('vm:entry-point')
Future<void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
  debugPrint('Notificação descartada: ${receivedAction.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

  // Inicializa Awesome Notifications
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Lembretes',
        channelDescription: 'Notificações de lembretes',
        defaultColor: Colors.blue,
        ledColor: Colors.white,
        importance: NotificationImportance.Max,
        channelShowBadge: true,
        onlyAlertOnce: false,
        playSound: true,
        criticalAlerts: true,
        enableLights: true,
        enableVibration: true,
      )
    ],
  );

  // Configura listeners para ações de notificação
  await AwesomeNotifications().setListeners(
    onActionReceivedMethod: onActionReceivedMethod,
    onNotificationCreatedMethod: onNotificationCreatedMethod,
    onNotificationDisplayedMethod: onNotificationDisplayedMethod,
    onDismissActionReceivedMethod: onDismissActionReceivedMethod,
  );

  // Solicita permissão para notificações
  if (!await AwesomeNotifications().isNotificationAllowed()) {
    await AwesomeNotifications().requestPermissionToSendNotifications(
      permissions: [
        NotificationPermission.Alert,
        NotificationPermission.Sound,
        NotificationPermission.Badge,
        NotificationPermission.Vibration,
        NotificationPermission.Light,
        NotificationPermission.PreciseAlarms,
        NotificationPermission.FullScreenIntent,
      ],
    );
  }

  // Debug: lista todas as notificações agendadas ao iniciar o app
  final schedules = await AwesomeNotifications().listScheduledNotifications();
  debugPrint('Notificações agendadas ao iniciar: ${schedules.length}');
  for (var schedule in schedules) {
    debugPrint('ID: ${schedule.content?.id}, Título: ${schedule.content?.title}, Agendada para: ${schedule.schedule?.toMap()}');
  }

  runApp(Listvo());
}

class Listvo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoriaProvider()),
        ChangeNotifierProvider(create: (_) => TarefaProvider()),
        ChangeNotifierProvider(create: (_) => LembreteProvider()),
      ],
      child: MaterialApp(
        initialRoute: '/',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
        ),
        builder: (context, child) {
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return Center(
              child: Text(
                'Ocorreu um erro na aplicação.\nPor favor, reinicie o app.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            );
          };
          return child ?? Container();
        },
        routes: {
          '/': (context) => AuthWrapper(),
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/cadastro': (context) => CadastroScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Provider.of<AuthProvider>(context, listen: false).checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final authProvider = Provider.of<AuthProvider>(context);
          if (authProvider.usuario != null) {
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
