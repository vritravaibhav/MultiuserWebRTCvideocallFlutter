import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtcvideocall/services/signaling.dart';
import 'package:crypto/crypto.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Signaling signaling = Signaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');

  @override
  void initState() {
   
    signaling.openUserMedia(_localRenderer, _remoteRenderer);

    _localRenderer.initialize();
    _remoteRenderer.initialize();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to Flutter Explained - WebRTC"),
      ),
      body: Column(
        children: [
          SizedBox(height: 8),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [

          //   ],
          // ),
          // ElevatedButton(
          //       onPressed: () {
          //       },
          //       child: Text("Open camera & microphone"),
          //     ),
          SizedBox(
            width: 8,
          ),
          ElevatedButton(
            onPressed: () async {
              roomId = await signaling.createRoom(
                  _remoteRenderer, textEditingController.text);
              textEditingController.text = roomId!;
              setState(() {});
            },
            child: Text("Create room"),
          ),
          SizedBox(
            width: 8,
          ),
          ElevatedButton(
            onPressed: () {
              // Add roomId
              signaling.joinRoom(
                textEditingController.text.trim(),
                _remoteRenderer,
              );
            },
            child: Text("Join room"),
          ),
          SizedBox(
            width: 8,
          ),
          ElevatedButton(
            onPressed: () {
              signaling.hangUp(_localRenderer, textEditingController.text);
            },
            child: Text("Hangup"),
          ),
          SizedBox(height: 8),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                  Expanded(child: RTCVideoView(_remoteRenderer)),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(child: RTCVideoView(_remoteRenderer)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Join the following Room: "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 8)
        ],
      ),
    );
  }
}
