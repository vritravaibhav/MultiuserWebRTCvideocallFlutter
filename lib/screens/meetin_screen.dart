// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({
    Key? key,
    required this.id, required this.list,
  }) : super(key: key);
  final String id;
final List list;
  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    listen();
  }

  listen() {
    FirebaseFirestore.instance
        .collection(widget.id)
        .snapshots()
        .listen((event) {
      for (var doc in event.docs) {
        Map<String, dynamic> temp = doc.data();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meeting Screen"),
      ),
      body: Column(
        children: [

        ],
      ),
    );
  }
}
