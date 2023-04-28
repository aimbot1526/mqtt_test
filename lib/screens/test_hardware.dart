import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_project/services/helper_functions.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_sound/flutter_sound.dart';

class TestHardware extends StatefulWidget {
  const TestHardware({super.key});

  @override
  State<TestHardware> createState() => _TestHardwareState();
}

class _TestHardwareState extends State<TestHardware> {
  bool _isLoading = true;
  bool _isRecording = false;
  String recordBtn = "Record Video";
  String audioBtn = "Record Audio";
  late CameraController _cameraController;
  final FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  String? pathToAudio;
  bool isAudioRecording = false;

  @override
  void initState() {
    _initCamera();
    initializer();
    super.initState();
  }

  void initializer() async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss \n EEE d MMM').format(now);
    pathToAudio = "${HelperFunctions.customFileFolder}/TestFlutter/test.wav";
    await _mRecorder.openRecorder();
    await _mRecorder.setSubscriptionDuration(const Duration(milliseconds: 10));
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  Future<void> startRecording() async {
    Directory directory = Directory(path.dirname(pathToAudio!));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    _mRecorder.openRecorder();
    await _mRecorder.startRecorder(
      toFile: pathToAudio,
      codec: Codec.pcm16WAV,
    );
    setState(() {
      audioBtn = "Stop";
    });
  }

  void stopRecorder() {
    _mRecorder.stopRecorder().then((value) {
      setState(() {
        isAudioRecording = true;
        audioBtn = "Record Audio";
      });
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _mRecorder.closeRecorder();
    super.dispose();
  }

  _initCamera() async {
    final cameras = await availableCameras();
    final back = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back);
    // if(back.lensDirection)
    _cameraController = CameraController(back, ResolutionPreset.max);
    await _cameraController.initialize();
    setState(() => _isLoading = false);
  }

  _recordVideo() async {
    if (_isRecording) {
      final file = await _cameraController.stopVideoRecording();
      setState(() {
        _isRecording = false;
        recordBtn = "Record Video";
      });
      await HelperFunctions.saveXFileToFolder(file);
    } else {
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() {
        _isRecording = true;
        recordBtn = "Stop";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Test"),
          ),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width,
                        child: CameraPreview(_cameraController),
                      )
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _recordVideo();
                        },
                        child: Text(recordBtn),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          audioBtn == "Record Audio"
                              ? startRecording()
                              : stopRecorder();
                        },
                        child: Text(audioBtn),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final image = await _cameraController.takePicture();
                          await HelperFunctions.saveXFileToFolder(image);
                        },
                        child: const Text("Take photo"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {},
                    child: const Text("Check Files"),
                  ),
                ],
              )
            ],
          ));
    }
  }
}
