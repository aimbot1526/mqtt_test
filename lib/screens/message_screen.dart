import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:test_project/models/message_model.dart';
import 'package:test_project/services/conn_state.dart';
import 'package:test_project/services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MessageScreen extends StatefulWidget {
  final MQTTService mqttService;

  const MessageScreen({Key key, this.mqttService}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  bool isConnected;
  StreamSubscription<ConnState> _cnxSubscription;
  final TextEditingController _messageController = TextEditingController();
  StreamController<List<MessageModel>> chatController =
      StreamController.broadcast();
  List<MessageModel> messageList = [];
  @override
  void dispose() {
    _messageController.dispose();
    chatController.close();
    _cnxSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    MQTTService.client.subscribe('publishing-messages', MqttQos.atMostOnce);
    MQTTService.client.updates.listen((dynamic t) {
      final MqttPublishMessage recMess = t[0].payload;
      final message = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );
      final data = jsonDecode(message);
      setState(() {
        messageList.add(
            MessageModel(message: data['message'], sentBy: data['sentBy']));
      });
      chatController.add(messageList);
    });
    _cnxSubscription = MQTTService.connectionStateStream().listen((state) {
      log('This is the connection state now:$state');
      setState(() {
        isConnected = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isConnected == true ? Colors.green : Colors.red,
        title: const Text('Messages'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: chatController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data[index];
                      return Message(
                        text: data.message,
                        isSent: data.sentBy == "User 1",
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Center(
                      child: Text("Start conversation"),
                    ),
                  );
                }
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Send a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      setState(() {
                        // Add new message to the bottom of the list
                        messageList.add(
                          MessageModel(
                            message: _messageController.text,
                            sentBy: "User 1",
                          ),
                        );
                        widget.mqttService.publish(
                          "reciever-messages",
                          jsonEncode(
                            MessageModel(
                              message: _messageController.text,
                              sentBy: "User 1",
                            ),
                          ),
                        );
                        _messageController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message extends StatelessWidget {
  final String text;
  final bool isSent;

  const Message({
    Key key,
     this.text,
     this.isSent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: isSent ? theme.primaryColor : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSent ? theme.colorScheme.onPrimary : null,
          ),
        ),
      ),
    );
  }
}
