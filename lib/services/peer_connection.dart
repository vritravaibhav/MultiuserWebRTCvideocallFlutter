import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class PeerConnection {
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  // String? roomId;

  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  // PeerConnectionfunc({required String text}) async {
  //   List data = [];
  //   print("bta not1");

  //   final snapshot = await FirebaseFirestore.instance.collection(text).get();
  //   print("bta not2");

  //   if (snapshot.size == 0) {
  //     print("bta not");
  //     return [];
  //   }
  //   DocumentReference ref = FirebaseFirestore.instance.collection(text).doc();
  //   print("bta not3");

  //   peerConnection = await createPeerConnection(configuration);
  //   peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
  //     FirebaseFirestore.instance.collection(text).doc(ref.id).set({
  //       "localIceCandidates": FieldValue.arrayUnion([candidate.toMap()])
  //     }, SetOptions(merge: true));
  //     data.add(candidate);
  //     print("bta candidate");
  //   };

  //   RTCSessionDescription offer = await peerConnection!.createOffer();
  //   await peerConnection!.setLocalDescription(offer);
  //   data.insert(0, offer);
  //   FirebaseFirestore.instance
  //       .collection(text)
  //       .doc(ref.id)
  //       .set({"offer": offer.toMap()}, SetOptions(merge: true));
  //   return data;
  //   // await peerConnection!.setLocalDescription(offer);
  // }

  Future<List<dynamic>> generateIceCandidatePeerConnection(
      {required String text}) async {
    List<dynamic> data = [];
    print("Step 1: Starting the function");

    final snapshot = await FirebaseFirestore.instance.collection(text).get();
    print("Step 2: Firestore snapshot obtained");

    if (snapshot.size == 0) {
      print("Step 3: No documents found in Firestore collection");
      return [];
    }

    DocumentReference ref = FirebaseFirestore.instance.collection(text).doc();
    print("Step 4: Firestore document reference created");

    // Configuration for the PeerConnection
    Map<String, dynamic> configuration = {
      "iceServers": [
        {"urls": "stun:stun.l.google.com:19302"},
        {"urls": "stun:stun1.l.google.com:19302"},
      ]
    };

    RTCPeerConnection? peerConnection;
    try {
      peerConnection = await createPeerConnection(configuration);
      print("Step 5: PeerConnection created");
    } catch (e) {
      print("Error creating PeerConnection: $e");
      return [];
    }




      localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });


    peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      print("ICE Candidate received: ${candidate.toMap()}");
      FirebaseFirestore.instance.collection(text).doc(ref.id).set({
        "localIceCandidates": FieldValue.arrayUnion([candidate.toMap()])
      }, SetOptions(merge: true));
      data.add(candidate);
    };

    peerConnection.onIceGatheringState = (RTCIceGatheringState state) {
      print("ICE Gathering State: $state");
    };

    peerConnection.onIceConnectionState = (RTCIceConnectionState state) {
      print("ICE Connection State: $state");
    };

    RTCSessionDescription offer;
    try {
      offer = await peerConnection.createOffer();
      // await peerConnection.setLocalDescription(offer);
      data.insert(0, offer);
      await FirebaseFirestore.instance
          .collection(text)
          .doc(ref.id)
          .set({"offer": offer.toMap()}, SetOptions(merge: true));
      print("Step 6: Offer created and saved to Firestore");
    } catch (e) {
      print("Error creating or setting local description: $e");
      return [];
    }


peerConnection.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };
    // Wait for ICE gathering to complete
    await Future.delayed(Duration(seconds: 3)); // Adjust the duration as needed
    print("Step 7: ICE gathering completed");

    return data;
  }
}
