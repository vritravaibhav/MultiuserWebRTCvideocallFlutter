import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtcvideocall/screens/meetin_screen.dart';
import 'package:webrtcvideocall/services/peer_connection.dart';
import 'package:webrtcvideocall/utils/uuid.dart';

class HomeScreenV1 extends StatefulWidget {
  const HomeScreenV1({super.key});

  @override
  State<HomeScreenV1> createState() => _HomeScreenV1State();
}

class _HomeScreenV1State extends State<HomeScreenV1> {
  TextEditingController x = TextEditingController();
  List value = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Multi user video call"),
      ),
      body: Padding(
        padding: EdgeInsets.all(0),
        child: Column(
          children: [
            TextField(
              controller: x,
            ),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () async{
                      if (x.text.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("hehe")));
                        return;
                      } else {
                        // FirebaseFirestore.instance
                        //     .collection(x.text)
                        //     .snapshots()
                        //     .listen((event) {
                        //   for (var doc in event.docs) {
                        //     // Map<String, dynamic> temp = doc.data();
                        //     PeerConnection().joinRoom(
                        //         docId: doc.id, collectionName: x.text);
                        //   }
                        // });
                      String uid = await loadUserId();
                         FirebaseFirestore.instance
                            .collection(x.text)
                            .doc(uid)
                            .set({"uid": uid});

                        Navigator.push(context, MaterialPageRoute(builder: (context){
                          return MeetingScreen(roomId: x.text, uid: uid);
                        }));
                      }
                    },
                    child: Text("Create room")),
                ElevatedButton(
                    onPressed: () async {
                      if (x.text.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("hehe")));
                        return;
                      } else {
                        String uid = await loadUserId();
                        FirebaseFirestore.instance
                            .collection(x.text)
                            .doc(uid)
                            .set({"uid": uid});
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MeetingScreen(roomId: x.text, uid: uid,),));
                      }
                    },
                    child: Text("Join room")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
