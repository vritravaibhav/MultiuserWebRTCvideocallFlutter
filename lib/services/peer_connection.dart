// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:webrtcvideocall/utils/uuid.dart';

class PeerConnection {
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  // String? roomId;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

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

  // Future<List<dynamic>> generateIceCandidatePeerConnection(
  //     {required String text}) async {
  //   List<dynamic> data = [];
  //   print("Step 1: Starting the function");

  //   final snapshot = await FirebaseFirestore.instance.collection(text).get();
  //   print("Step 2: Firestore snapshot obtained");

  //   if (snapshot.size == 0) {
  //     print("Step 3: No documents found in Firestore collection");
  //     return [];
  //   }

  //   DocumentReference ref = FirebaseFirestore.instance.collection(text).doc();
  //   print("Step 4: Firestore document reference created");

  //   // Configuration for the PeerConnection
  //   Map<String, dynamic> configuration = {
  //     "iceServers": [
  //       {"urls": "stun:stun.l.google.com:19302"},
  //       {"urls": "stun:stun1.l.google.com:19302"},
  //     ]
  //   };

  //   RTCPeerConnection? peerConnection;
  //   try {
  //     peerConnection = await createPeerConnection(configuration);
  //     print("Step 5: PeerConnection created");
  //   } catch (e) {
  //     print("Error creating PeerConnection: $e");
  //     return [];
  //   }

  //   localStream?.getTracks().forEach((track) {
  //     peerConnection?.addTrack(track, localStream!);
  //   });

  //   peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
  //     print("ICE Candidate received: ${candidate.toMap()}");
  //     FirebaseFirestore.instance.collection(text).doc(ref.id).set({
  //       "localIceCandidates": FieldValue.arrayUnion([candidate.toMap()])
  //     }, SetOptions(merge: true));
  //     data.add(candidate);
  //   };

  //   peerConnection.onIceGatheringState = (RTCIceGatheringState state) {
  //     print("ICE Gathering State: $state");
  //   };

  //   peerConnection.onIceConnectionState = (RTCIceConnectionState state) {
  //     print("ICE Connection State: $state");
  //   };

  //   RTCSessionDescription offer;
  //   try {
  //     offer = await peerConnection.createOffer();
  //     // await peerConnection.setLocalDescription(offer);
  //     data.insert(0, offer);
  //     await FirebaseFirestore.instance
  //         .collection(text)
  //         .doc(ref.id)
  //         .set({"offer": offer.toMap()}, SetOptions(merge: true));
  //     print("Step 6: Offer created and saved to Firestore");
  //   } catch (e) {
  //     print("Error creating or setting local description: $e");
  //     return [];
  //   }

  //   peerConnection.onTrack = (RTCTrackEvent event) {
  //     print('Got remote track: ${event.streams[0]}');

  //     event.streams[0].getTracks().forEach((track) {
  //       print('Add a track to the remoteStream $track');
  //       remoteStream?.addTrack(track);
  //     });
  //   };
  //   // Wait for ICE gathering to complete
  //   await Future.delayed(Duration(seconds: 3)); // Adjust the duration as needed
  //   print("Step 7: ICE gathering completed");

  //   return data;
  // }

  Future<VideoUserCall> joinRoom(
      {required String docId, required String collectionName}) async {
    try {
      peerConnection = await createPeerConnection(configuration);
      print("Step 5: PeerConnection created");
    } catch (e) {
      print("Error creating PeerConnection: $e");
      throw e;
    }
    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });
    String uid = await loadUserId();
    List data = [];
    peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      print("ICE Candidate received: ${candidate.toMap()}");
      FirebaseFirestore.instance
          .collection(collectionName)
          .doc(docId)
          .collection("rooms")
          .doc(uid)
          .set({
        "localIceCandidates": FieldValue.arrayUnion([candidate.toMap()])
      }, SetOptions(merge: true));
    };
    RTCSessionDescription offer;
    try {
      offer = await peerConnection!.createOffer();
      await peerConnection!.setLocalDescription(offer);
      data.insert(0, offer);
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(docId)
          .collection("rooms")
          .doc(uid)
          .set({"offer": offer.toMap()}, SetOptions(merge: true));
      print("Step 6: Offer created and saved to Firestore");
    } catch (e) {
      print("Error creating or setting local description: $e");
      throw e;
    }
    peerConnection!.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };

    final docRef = FirebaseFirestore.instance
        .collection(collectionName)
        .doc(docId)
        .collection("rooms")
        .doc(uid);
    docRef.snapshots().listen(
      (event) async {
        Map<String, dynamic>? answerData = event.data();
        print("bta answers ${answerData!['answer']['type']}");
        var answer = RTCSessionDescription(
          answerData!['answer']['sdp'],
          answerData['answer']['type'],
        );
        await peerConnection?.setRemoteDescription(answer);
      },
      onError: (error) => print("Listen failed: $error"),
    );

    final docRef2 = FirebaseFirestore.instance
        .collection(collectionName)
        .doc(docId)
        .collection("rooms")
        .doc(uid);
    docRef2.snapshots().listen(
      (event) async {
        Map<String, dynamic>? answerData = event.data();

        for (var element in answerData!["remoteIceCandidate"]) {
          peerConnection!.addCandidate(
            RTCIceCandidate(
              element['candidate'],
              element['sdpMid'],
              element['sdpMLineIndex'],
            ),
          );
        }
      },
      onError: (error) => print("Listen failed: $error"),
    );
    return VideoUserCall(localVideo: localStream!, remoteVideo: remoteStream!);
  }

  Future<VideoUserCall> addinRoom(
      {required String collectionName,
      required String docId,
      required String refuid,
      required Map<String, dynamic> uidData}) async {
    print("bta mapdata uid data ${uidData["localIceCandidates"]}");
    peerConnection = await createPeerConnection(configuration);
    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });
    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      FirebaseFirestore.instance
          .collection(collectionName)
          .doc(docId)
          .collection("rooms")
          .doc(refuid)
          .set({
        "remoteIceCandidate": FieldValue.arrayUnion([candidate.toMap()])
      }, SetOptions(merge: true));
    };

    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');
      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream: $track');
        remoteStream?.addTrack(track);
      });
    };
    await peerConnection?.setRemoteDescription(
      RTCSessionDescription(uidData['offer']['sdp'], uidData['offer']['type']),
    );
    var answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);
    FirebaseFirestore.instance
        .collection(collectionName)
        .doc(docId)
        .collection("rooms")
        .doc(refuid)
        .set({"answer": answer.toMap()}, SetOptions(merge: true));

    for (var element in uidData["localIceCandidates"]) {
      peerConnection!.addCandidate(
        RTCIceCandidate(
          element['candidate'],
          element['sdpMid'],
          element['sdpMLineIndex'],
        ),
      );
    }
    if (localStream != null && remoteStream != null) {
      return VideoUserCall(
          localVideo: localStream!, remoteVideo: remoteStream!);
    } else {
      throw 0;
    }
  }

  Future<void> openUserMedia(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    var stream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': true});

    localVideo.srcObject = stream;
    localStream = stream;

    remoteVideo.srcObject = await createLocalMediaStream('key');
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE connection state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      print("Add remote stream");
      // onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }
}

class VideoUserCall {
  MediaStream localVideo;
  MediaStream remoteVideo;
  VideoUserCall({
    required this.localVideo,
    required this.remoteVideo,
  });
}
