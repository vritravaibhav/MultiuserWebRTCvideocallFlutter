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
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            TextField(
              controller: x,
              decoration: InputDecoration(
                labelText: 'Enter text',
                hintText: 'Type something here...',
                prefixIcon: Icon(Icons.video_call),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.green, width: 2.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    x.clear();
                  },
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(
              height: 10,
            ),
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MeetingScreen(
                            roomId: x.text,
                            uid: uid,
                          ),
                        ));
                  }
                },
                child: Text("Join room"))
          ],
        ),
      ),
    );
  }
}
