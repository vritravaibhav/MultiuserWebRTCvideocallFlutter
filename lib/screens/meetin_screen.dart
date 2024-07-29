// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

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
    // _localRenderer.initialize();

    // _getUserMedialocal();

    listenOld();
    // listenNew();
  }

  List<PeerConnection> list = [];
  List<String> docId = [];
  listenNew() async {
    await FirebaseFirestore.instance
        .collection(widget.roomId)
        .doc(widget.uid)
        .collection("rooms")
        .get()
        .then((event) async {
      print("bta listennew v2 ${event.docs.length}");

      for (var doc in event.docs) {
        // cities.add(doc.data()["name"]);
        if (docId.contains(doc.id)) {
          setState(() {});
          continue;
        }
        docId.add(doc.id);
        PeerConnection temp = PeerConnection();
        RTCVideoRenderer tempRemoteRenderer = RTCVideoRenderer();
        // temp.openUserMedia(_localRenderer, tempRemoteRenderer);

        // tempRemoteRenderer.initialize();

        // temp.onAddRemoteStream = ((stream) {
        //   tempRemoteRenderer.srcObject = stream;
        //   setState(() {});
        // });
        listenNewList.add([widget.roomId, widget.uid, doc.id, doc.data()]);
        // await temp.addinRoom(
        //     collectionName: widget.roomId,
        //     docId: widget.uid,
        //     refuid: doc.id,
        //     uidData: doc.data());

        list.add(temp);
        setState(() {});
      }

      // print("cities in CA: ${cities.join(", ")}");
    });
  }

  bool isLoading = true;
  List<List<String>> listenOldlist = [];
  List<List<dynamic>> listenNewList = [];

  Future<void> listenOld() async {
    await FirebaseFirestore.instance
        .collection(widget.roomId)
        .get()
        .then((event) async {
      print("${event.docs.length} bta length");
      for (var doc in event.docs) {
        // Map<String, dynamic> temp = doc.data();
        if (doc.id != widget.uid) {
          PeerConnection temp = PeerConnection();
          // RTCVideoRenderer tempRemoteRenderer = RTCVideoRenderer();
          // temp.openUserMedia(_localRenderer, tempRemoteRenderer);
          // tempRemoteRenderer.initialize();
          // temp.onAddRemoteStream = ((stream) {
          //   tempRemoteRenderer.srcObject = stream;
          //   setState(() {});
          // });
          print("bta entered in listen o;f");
          listenOldlist.add([doc.id, widget.roomId]);
          //  await temp.joinRoom(docId: doc.id, collectionName: widget.roomId);

          list.add(temp);
        }
      }
    });
    print("bta listwnew");

    await listenNew();
    isLoading = false;
    setState(() {});
  }

  // RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  // RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  // MediaStream? _localStream;
  // Future<RTCVideoRenderer> _getUserMedia(
  //     RTCVideoRenderer _remoteRenderer, MediaStream yourRemoteStream) async {
  //   final Map<String, dynamic> mediaConstraints = {
  //     'audio': true,
  //     'video': true,
  //   };

  //   try {
  //     _localStream =
  //         await navigator.mediaDevices.getUserMedia(mediaConstraints);
  //     _localRenderer.srcObject = _localStream;

  //     // Example of setting the remote stream, replace with your actual remote stream
  //     _remoteRenderer.srcObject = yourRemoteStream;
  //     return _remoteRenderer;
  //   } catch (e) {
  //     print('Error: $e');
  //     throw e;
  //   }
  // }

  // Future<void> _getUserMedialocal() async {
  //   final Map<String, dynamic> mediaConstraints = {
  //     'audio': true,
  //     'video': true
  //   };

  //   try {
  //     _localStream =
  //         await navigator.mediaDevices.getUserMedia(mediaConstraints);
  //     _localRenderer.srcObject = _localStream;

  //     // Example of setting the remote stream, replace with your actual remote stream
  //     // _remoteRenderer.srcObject = yourRemoteStream;
  //     // return _remoteRenderer;
  //   } catch (e) {
  //     print('Error: $e');
  //     throw e;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // listenNew();
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            floatingActionButton: ElevatedButton(
              child: Text("refresh"),
              onPressed: () {
                listenNew();
                setState(() {});
              },
            ),
            appBar: AppBar(
              title: Text("Meeting Screen"),
            ),
            body: Column(
              children: [
                // Builder(builder: (context) {
                //   _localRenderer.initialize();

                //   return SizedBox(
                //     height: 200,
                //     child: RTCVideoView(_localRenderer),
                //   );
                // }),
                // for (int i = 0; i < list.length; i++)
                //   UserScreen(
                //     peerConnection: list[i],
                //   ),

                for (int i = 0; i < listenOldlist.length; i++)
                  ListScreen(
                    list: listenOldlist[i],
                  ),
                for (int i = 0; i < listenNewList.length; i++)
                  ListNewScreen(
                    list: listenNewList[i],
                  ),
              ],
            ),
          );
  }
}

class UserScreen extends StatefulWidget {
  final PeerConnection peerConnection;
  const UserScreen({
    super.key,
    required this.peerConnection,
  });

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  @override
  void initState() {
    // TODO: implement initState

    widget.peerConnection.openUserMedia(_localRenderer, _remoteRenderer);
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    widget.peerConnection.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 200,
          width: 100,
          child: RTCVideoView(_localRenderer),
          // child: Container(
          //   color: Colors.red,
          // ),
        ),
        SizedBox(
          width: 10,
        ),
        SizedBox(
          width: 100,
          height: 200,
          child: RTCVideoView(
            _remoteRenderer,
            mirror: true,
          ),
          // child: Container(
          //   color: Colors.red,
          // ),
        ),
      ],
    );
  }
}

//------------------------------------------------------------------------//
class ListScreen extends StatefulWidget {
  final List list;
  const ListScreen({
    super.key,
    required this.list,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  PeerConnection peerConnection = PeerConnection();
  @override
  void initState() {
    // TODO: implement initState

    _localRenderer.initialize();
    _remoteRenderer.initialize();

    setState(() {
      peerConnection.onAddRemoteStream = ((stream) {
        _remoteRenderer.srcObject = stream;
      });
    });
    callFunction();

    super.initState();
  }

  callFunction() async {
    // setState(()  {
    await peerConnection.openUserMedia(_localRenderer, _remoteRenderer);

    await peerConnection.joinRoom(
        docId: widget.list[0], collectionName: widget.list[1]);
    // });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 200,
          width: 100,
          child: RTCVideoView(_localRenderer),
          // child: Container(
          //   color: Colors.red,
          // ),
        ),
        SizedBox(
          width: 10,
        ),
        SizedBox(
          width: 100,
          height: 200,
          child: RTCVideoView(
            _remoteRenderer,
            mirror: true,
          ),
          // child: Container(
          //   color: Colors.red,
          // ),
        ),
        ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            child: Text("lol")),
      ],
    );
  }
}

//=======================
class ListNewScreen extends StatefulWidget {
  final List list;
  const ListNewScreen({
    super.key,
    required this.list,
  });

  @override
  State<ListNewScreen> createState() => _ListNewScreenState();
}

class _ListNewScreenState extends State<ListNewScreen> {
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  PeerConnection peerConnection = PeerConnection();
  @override
  void initState() {
    // TODO: implement initState

    _localRenderer.initialize();
    _remoteRenderer.initialize();

    setState(() {
      peerConnection.onAddRemoteStream = ((stream) {
        _remoteRenderer.srcObject = stream;
      });
    });
    callFunction();

    super.initState();
  }

  callFunction() async {
    // setState(() {});
    // setState(() {
    await peerConnection.openUserMedia(_localRenderer, _remoteRenderer);

    await peerConnection.addinRoom(
        collectionName: widget.list[0],
        docId: widget.list[1],
        refuid: widget.list[2],
        uidData: widget.list[3]);
    // });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 200,
          width: 100,
          child: RTCVideoView(_localRenderer),
          // child: Container(
          //   color: Colors.red,
          // ),
        ),
        SizedBox(
          width: 10,
        ),
        SizedBox(
          width: 100,
          height: 200,
          child: RTCVideoView(
            _remoteRenderer,
            mirror: true,
          ),
          // child: Container(
          //   color: Colors.red,
          // ),
        ),
        ElevatedButton(
            onPressed: () {
              setState(() {});
            },
            child: Text("lol1"))
      ],
    );
  }
}
