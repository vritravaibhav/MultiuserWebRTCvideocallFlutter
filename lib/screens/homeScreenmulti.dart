import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webrtcvideocall/screens/meetin_screen.dart';
import 'package:webrtcvideocall/services/peer_connection.dart';

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
                    onPressed: () {
                      if (x.text.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("hehe")));
                        return;
                      } else {
                        FirebaseFirestore.instance.collection(x.text).add({});
                      }
                    },
                    child: Text("Create room")),
                ElevatedButton(
                    onPressed: () async {
                      if (x.text.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text("hehe")));
                        return;
                      }
                      value = await PeerConnection()
                          .generateIceCandidatePeerConnection(text: x.text);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return MeetingScreen(
                          id: x.text,
                          list: value,
                        );
                      }));
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
