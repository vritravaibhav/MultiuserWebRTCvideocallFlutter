// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtcvideocall/services/peer_connection.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({
    Key? key,
    required this.roomId,
    required this.uid,
  }) : super(key: key);
  final String roomId;
  final String uid;

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserMedialocal();

    // listenOld();
    _localRenderer.initialize();
    listenNew();
  }

  List<VideoUserCall> list = [];

  listenNew() async {
    // await FirebaseFirestore.instance
    //     .collection(widget.roomId)
    //     .get()
    //     .then((event) async {
    //   for (var doc in event.docs) {
    //     // Map<String, dynamic> temp = doc.data();
    //     if (doc.id != widget.uid) {
    //       VideoUserCall temp = await PeerConnection()
    //           .joinRoom(docId: doc.id, collectionName: widget.roomId);
    //       list.add(temp);
    //     }
    //   }
    // });

    await FirebaseFirestore.instance
        .collection(widget.roomId)
        .doc(widget.uid)
        .collection("rooms")
        .get()
        .then((event) async {
      for (var doc in event.docs) {
        // cities.add(doc.data()["name"]);
        var temp = await PeerConnection().addinRoom(
            collectionName: widget.roomId,
            docId: widget.uid,
            refuid: doc.id,
            uidData: doc.data());
        if (temp.runtimeType == VideoUserCall) {
          list.add(temp);
        }
      }
      // print("cities in CA: ${cities.join(", ")}");
    });
  }

  listenOld() {
    FirebaseFirestore.instance
        .collection(widget.roomId)
        .get()
        .then((event) async {
      for (var doc in event.docs) {
        // Map<String, dynamic> temp = doc.data();
        if (doc.id != widget.uid) {
          VideoUserCall temp = await PeerConnection()
              .joinRoom(docId: doc.id, collectionName: widget.roomId);
          list.add(temp);
        }
      }
    });
  }

  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  // RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  Future<RTCVideoRenderer> _getUserMedia(
      RTCVideoRenderer _remoteRenderer, MediaStream yourRemoteStream) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    };

    try {
      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;

      // Example of setting the remote stream, replace with your actual remote stream
      _remoteRenderer.srcObject = yourRemoteStream;
      return _remoteRenderer;
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  Future<void> _getUserMedialocal() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      },
    };

    try {
      _localStream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localRenderer.srcObject = _localStream;

      // Example of setting the remote stream, replace with your actual remote stream
      // _remoteRenderer.srcObject = yourRemoteStream;
      // return _remoteRenderer;
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    listenNew();
    // listenOld();

    return Scaffold(
      appBar: AppBar(
        title: Text("Meeting Screen"),
      ),
      body: Column(
        children: [
          Builder(builder: (context) {
            _localRenderer.initialize();

            return SizedBox(
              height: 200,
              child: RTCVideoView(_localRenderer),
            );
          }),
          for (int i = 0; i < list.length; i++)
            Builder(builder: (context) {
              RTCVideoRenderer temp = RTCVideoRenderer();
              temp.initialize();
              _getUserMedia(temp, list[i].remoteVideo);
              return SizedBox(
                height: 200,
                child: RTCVideoView(temp),
              );
            })
        ],
      ),
    );
  }
}
