import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class MultiUserSignaling {
  RTCVideoRenderer localRenderer = RTCVideoRenderer();
  RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
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

  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  MultiUserSignaling({required localRenderers, required remoteRenderers}) {
    this.localRenderer = localRenderers;
    this.remoteRenderer = remoteRenderer;
  }
  MultiUserSignalingfunc(
      {required List list,
      required Map<String, dynamic> temp,
      required String id,
      required String collectionName}) async {
    openUserMedia();
    registerPeerConnectionListeners();

    peerConnection = await createPeerConnection(configuration);
    List candidateList = [];
    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });
    peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) async {
      if (candidate == null) {
        print('onIceCandidate: complete!');
        return;
      }
      print('onIceCandidate: ${candidate.toMap()}');
      //aDD iCE
      candidateList.add(candidate);
    };
    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');
      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream: $track');
        remoteStream?.addTrack(track);
      });
    };

    await peerConnection?.setRemoteDescription(
      RTCSessionDescription(temp['offer']['sdp'], temp['offer']['type']),
    );
    var answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);
    await FirebaseFirestore.instance.collection(collectionName).doc(id).set({
      "answer": FieldValue.arrayUnion([
        {
          "sdp": answer.sdp,
          "type": answer.type,
          "iceCandidate": FieldValue.arrayUnion(candidateList)
        }
      ]),
    });

    for (var data in temp["localIceCandidates"]) {
      peerConnection!.addCandidate(
        RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex'],
        ),
      );
    }

    return MultiUserSignaling(
        localRenderers: localRenderer, remoteRenderers: remoteRenderer);
  }

  Future<void> openUserMedia() async {
    var stream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': true});

    localRenderer.srcObject = stream;
    localStream = stream;

    // remoteRenderer.srcObject = await createLocalMediaStream('key');
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
      remoteRenderer.srcObject = stream;
      //       remoteRenderer.srcObject = remoteStream.;

    };
  }


  ///Creatin function
  
  function(String docId,List list )async{
    openUserMedia();
          peerConnection = await createPeerConnection(configuration);
  localStream?.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream!);
      });
  }
}
