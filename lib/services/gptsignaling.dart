// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';

// class SignalingService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Join a room
//   Future<void> joinRoom(String roomId, RTCPeerConnection peerConnection, Function(RTCIceCandidate) onIceCandidate, Function(RTCSessionDescription) onOffer) async {
//     final roomRef = _firestore.collection('rooms').doc(roomId);
//     final roomSnapshot = await roomRef.get();

//     // Handle ICE candidates
//     peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
//       roomRef.collection('candidates').add(candidate.toMap());
//     };

//     if (roomSnapshot.exists) {
//       // Room already exists, join it
//       final roomData = roomSnapshot.data()!;
//       final answer = await peerConnection.createAnswer();
//       await peerConnection.setLocalDescription(answer);
//       roomRef.update({'answer': answer.toMap()});
//       onOffer(RTCSessionDescription(roomData['offer']['sdp'], roomData['offer']['type']));
//     } else {
//       // Create a new room
//       final offer = await peerConnection.createOffer();
//       await peerConnection.setLocalDescription(offer);
//       roomRef.set({'offer': offer.toMap()});
//     }

//     // Listen for remote ICE candidates
//     roomRef.collection('candidates').snapshots().listen((snapshot) {
//       for (var doc in snapshot.docChanges) {
//         if (doc.type == DocumentChangeType.added) {
//           onIceCandidate(RTCIceCandidate(doc.doc.data()!['candidate'], doc.doc.data()!['sdpMid'], doc.doc.data()!['sdpMLineIndex']));
//         }
//       }
//     });
//   }
// }
