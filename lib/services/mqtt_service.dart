import 'dart:async';
import 'dart:developer';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test_project/services/conn_state.dart';

class MQTTService{
  MQTTService({this.host, this.port, this.topic, this.msg});

  final String host;

  final int port;

  final String topic;

  String msg;

  static MqttServerClient client;

  static String updatedMsg;

  static bool isConnected = false;

  static final BehaviorSubject<ConnState> _cnxBehavior =
      BehaviorSubject<ConnState>();      

  Future<void> initializeMQTTClient() async {
    client = MqttServerClient(host, 'anshjj')
      ..port = port
      ..logging(on: false)
      ..onDisconnected = onDisConnected
      ..onSubscribed = onSubscribed
      ..keepAlivePeriod = 5
      ..onConnected = onConnected
      ..disconnectOnNoResponsePeriod = 5
      ..disconnectOnNoPingResponse(MyDisconnectOnNoPingResponse())
      ..autoReconnect = true;

    if(client.connectionStatus.state == MqttConnectionState.faulted) {
        print("Faluted true");
      }

    final connMess = MqttConnectMessage()
        .withClientIdentifier('anshjj')
        .startClean()
        .authenticateAs("cp", "smart@123");
    log('Connecting....');
    client.connectionMessage = connMess;
  }
  

  Future connectMQTT() async {
    try {
      _broadcastConnectionState();
      await client.connect();
      _broadcastConnectionState();
    } on NoConnectionException catch (e) {
      log(e.toString());
      client.disconnect();
    }
  }

  void disConnectMQTT() {
    try {
      client.disconnect();
    } catch (e) {
      log(e.toString());
    }
  }

  void onConnected() {
    log('Connected');
    isConnected = true;
    try {
    } catch (e) {
      log(e.toString());
    }
  }

  _broadcastConnectionState() {
    if (client == null) {
      _cnxBehavior.add(ConnState.disconnected);
      return;
    }
    if (client.connectionStatus == null) {
      _cnxBehavior.add(ConnState.disconnected);
      return;
    }
    switch (client.connectionStatus.state) {
      case MqttConnectionState.disconnecting:
        _cnxBehavior.add(ConnState.disconnecting);
        break;
      case MqttConnectionState.disconnected:
        _cnxBehavior.add(ConnState.disconnected);
        break;
      case MqttConnectionState.connecting:
        _cnxBehavior.add(ConnState.connecting);
        break;
      case MqttConnectionState.connected:
        _cnxBehavior.add(ConnState.connected);
        break;
      case MqttConnectionState.faulted:
        _cnxBehavior.add(ConnState.faulted);
        break;
    }
  }

  void onDisConnected() {
    log('Disconnected');
  }

  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    client.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      builder.payload,
    );
    builder.clear();
  }

  void onSubscribed(String topic) {
    log('Subscribed topic: $topic');
  }

  static Stream<ConnState> connectionStateStream() {
    return _cnxBehavior.stream;
  }
}

class MyDisconnectOnNoPingResponse extends DisconnectOnNoPingResponse {
  @override
  void disconnectNoResponse(MqttClient client) {
    // Add your custom code here to handle the disconnect event.
    print("no response comming");
  }
}