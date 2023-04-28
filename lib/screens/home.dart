import 'package:flutter/material.dart';
import 'package:test_project/screens/message_screen.dart';
import 'package:test_project/services/helper_functions.dart';
import 'package:is_lock_screen/is_lock_screen.dart';
import 'package:test_project/screens/test_hardware.dart';
import 'package:test_project/screens/navigation_screen.dart';
import 'package:test_project/services/mqtt_service.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  Home({super.key, required this.title});
  String title;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final MQTTService _service = MQTTService(
    host: 'kkk.smart24x7.com',
    port: 1883,
    topic: 'messages',
  );
  void getLoc() async {
    Map<String, String> location =
        await HelperFunctions.getCurrentPosition(context);
    await HelperFunctions.changeImageToMarker();
    _service.publish("location-status", location.toString());
  }

  Future<bool?> checkScreen() async {
    return await isLockScreen();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.microphone.request();
    final storageStatus = await Permission.storage.request();
    if (status != PermissionStatus.granted &&
        storageStatus != PermissionStatus.granted) {
      throw Exception('Permission to record audio not granted');
    }
  }

  @override
  void initState() {
    _service.initializeMQTTClient();
    _service.connectMQTT();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: getLoc,
              child: const Text("Take Location"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                bool? isLock = await checkScreen();
                _service.publish("screen-status", isLock.toString());
              },
              child: const Text("Check Screen"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                _requestPermissions();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TestHardware(),
                  ),
                );
              },
              child: const Text("Test Hardware"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MessageScreen(mqttService: _service),
                  ),
                );
              },
              child: const Text("MQTT Test"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NavigationScreen(),
                  ),
                );
              },
              child: const Text("Show location"),
            ),
          ],
        ),
      ),
    );
  }
}
