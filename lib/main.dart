import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';

const String _widgetTaskName = 'clockWidgetUpdate';
const String _widgetName = 'ClockWidgetProvider';
const String _appGroupId = 'com.example.clock_app';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    await _pushDateToWidget();
    return Future.value(true);
  });
}

Future<void> _pushDateToWidget() async {
  final now = DateTime.now();
  await HomeWidget.saveWidgetData<String>(
    'clock_date',
    DateFormat('EEE, d MMM yyyy').format(now),
  );
  await HomeWidget.updateWidget(androidName: _widgetName);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.setAppGroupId(_appGroupId);
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    _widgetTaskName,
    _widgetTaskName,
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    constraints: Constraints(networkType: NetworkType.notRequired),
  );
  runApp(const ClockApp());
}

class ClockApp extends StatelessWidget {
  const ClockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF64FFDA),
          surface: Color(0xFF0A0A0F),
        ),
      ),
      home: const ClockScreen(),
    );
  }
}

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
    _pushDateToWidget();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _timeHHmm => DateFormat('HH:mm').format(_now);
  String get _seconds => DateFormat('ss').format(_now);
  String get _amPm => DateFormat('a').format(_now);
  String get _dateString => DateFormat('EEEE, d MMMM yyyy').format(_now);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _dateString,
                style: const TextStyle(
                  color: Color(0xFF64FFDA),
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _timeHHmm,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.w100,
                      letterSpacing: -2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      ':$_seconds',
                      style: TextStyle(
                        color: const Color(0xFF64FFDA).withOpacity(0.85),
                        fontSize: 40,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 8),
                    child: Text(
                      _amPm,
                      style: const TextStyle(
                        color: Color(0xFF8892B0),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF64FFDA).withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Long-press your home screen to add the Clock Widget.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF8892B0),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
