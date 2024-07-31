// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtcvideocall/services/peer_connection.dart';

MediaStream? stream;

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

    // _getUserMedialocal();

    listenOld();
    _localRenderer.initialize();
    // listenNew();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _localRenderer.dispose();
    super.dispose();
  }

  RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  List<List<dynamic>> list = [];
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

        list.add([widget.roomId, widget.uid, doc.id, doc.data()]);
      }
      setState(() {});

      // print("cities in CA: ${cities.join(", ")}");
    });
  }

  bool isLoading = true;
  // List<List<String>> listenOldlist = [];
  // List<List<dynamic>> listenNewList = [];

  Future<void> listenOld() async {
    stream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': true});
    _localRenderer.srcObject = stream;
    await FirebaseFirestore.instance
        .collection(widget.roomId)
        .get()
        .then((event) async {
      print("${event.docs.length} bta length");
      for (var doc in event.docs) {
        if (doc.id != widget.uid) {
          list.add([doc.id, widget.roomId]);
        }
      }
    });
    isLoading = false;
    setState(() {});

    FirebaseFirestore.instance
        .collection(widget.roomId)
        .doc(widget.uid)
        .collection("rooms")
        .snapshots()
        .listen((event) async {
      // await Future.delayed(Duration(seconds: 5));
      listenNew();
    });
  }

  @override
  Widget build(BuildContext context) {
    // listenNew();
    return isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            // floatingActionButton: ElevatedButton(
            //   child: Text("refresh"),
            //   onPressed: () {
            //     listenNew();
            //   },
            // ),
            appBar: AppBar(
              title: Text("Meeting Screen"),
            ),
            body: SizedBox(
              height: MediaQuery.of(context).size.height - 100,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Builder(builder: (context) {
                    //   _localRenderer.initialize();

                    // Align(
                    //   alignment: Alignment.topLeft,
                    //   child: SizedBox(
                    //     height: 400,
                    //     child: RTCVideoView(_localRenderer,
                    //         objectFit: RTCVideoViewObjectFit
                    //             .RTCVideoViewObjectFitCover),
                    //   ),
                    // ),
                    Text(
                      "${widget.roomId}",
                      style: TextStyle(color: Colors.black),
                    ),
                    // }),
                    // for (int i = 0; i < list.length; i++)
                    //   UserScreen(
                    //     peerConnection: list[i],
                    //   ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 60,
                      child: GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: ((list.length + 1) / 3)
                            .ceilToDouble()
                            .toInt(), // Number of items in the cross axis
                        crossAxisSpacing:
                            8.0, // Space between items in the cross axis
                        mainAxisSpacing:
                            8.0, // Space between items in the main axis
                        children: List.generate(list.length + 1, (index) {
                          if (index == list.length) {
                            return RTCVideoView(_localRenderer,
                                mirror: true,
                                objectFit: RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover);
                          }
                          print("bta list lenght${list.length}");
                          return Container(
                              color: Colors.red,
                              child: ListScreen(
                                list: list[index],
                              ));
                        }),
                      ),
                    ),

                    // for (int i = 0; i < list.length; i++)
                    //   ListScreen(
                    //     list: list[i],
                    //   ),
                    // for (int i = 0; i < listenNewList.length; i++)
                    //   ListNewScreen(
                    //     list: listenNewList[i],
                    //   ),
                  ],
                ),
              ),
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
    print("bta call function");
    print("bta list length l${widget.list.length}");

    peerConnection.localStream = stream;

    await peerConnection.openUserMedia(_localRenderer, _remoteRenderer);
    if (widget.list.length == 2) {
      await peerConnection.joinRoom(
          docId: widget.list[0], collectionName: widget.list[1]);
      // });
    } else {
      await peerConnection.addinRoom(
          collectionName: widget.list[0],
          docId: widget.list[1],
          refuid: widget.list[2],
          uidData: widget.list[3]);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print("render bta");
    return RTCVideoView(
      _remoteRenderer,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      mirror: true,
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
    peerConnection.localStream = stream;
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
        // SizedBox(
        //   height: 200,
        //   width: 100,
        //   child: RTCVideoView(_localRenderer),
        //   // child: Container(
        //   //   color: Colors.red,
        //   // ),
        // ),
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
