// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:webrtcvideocall/services/gptsignaling.dart';

// class VideoCallScreen extends StatefulWidget {
//   final String roomId;

//   VideoCallScreen({required this.roomId});

//   @override
//   _VideoCallScreenState createState() => _VideoCallScreenState();
// }

// class _VideoCallScreenState extends State<VideoCallScreen> {
//   final SignalingService _signalingService = SignalingService();
//   final Map<String, RTCPeerConnection> _peerConnections = {};
//   final Map<String, RTCVideoRenderer> _remoteRenderers = {};
//   late RTCVideoRenderer _localRenderer;

//   @override
//   void initState() {
//     super.initState();
//     _initializeLocalRenderer();
//     _joinRoom();
//     setState(() {});
//   }

//   Future<void> _initializeLocalRenderer() async {
//     _localRenderer = RTCVideoRenderer();
//     await _localRenderer.initialize();
//     final localStream = await navigator.mediaDevices
//         .getUserMedia({'video': true, 'audio': true});
//     _localRenderer.srcObject = localStream;
//   }

//   Future<void> _joinRoom() async {
//     final config = {
//       'iceServers': [
//         {'urls': 'stun:stun.l.google.com:19302'},
//       ],
//     };
//     final constraints = {
//       'mandatory': {
//         'OfferToReceiveAudio': true,
//         'OfferToReceiveVideo': true,
//       },
//       'optional': [],
//     };

//     final peerConnection = await createPeerConnection(config, constraints);
//     _peerConnections[widget.roomId] = peerConnection;

//     // Handle ICE candidates
//     peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
//       _signalingService.joinRoom(widget.roomId, peerConnection,
//           (RTCIceCandidate candidate) {
//         peerConnection.addCandidate(candidate);
//       }, (RTCSessionDescription offer) async {
//         await peerConnection.setRemoteDescription(offer);
//       });
//     };

//     // Handle remote streams
//     peerConnection.onAddStream = (MediaStream stream) {
//       final renderer = RTCVideoRenderer();
//       renderer.initialize();
//       renderer.srcObject = stream;
//       setState(() {
//         _remoteRenderers[stream.id] = renderer;
//       });
//     };
//   }

//   @override
//   void dispose() {
//     _localRenderer.dispose();
//     _peerConnections.forEach((key, connection) {
//       connection.dispose();
//     });
//     _remoteRenderers.forEach((key, renderer) {
//       renderer.dispose();
//     });
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Video Call')),
//       body: Column(
//         children: [
//           Expanded(
//             child: RTCVideoView(_localRenderer),
//           ),
//           Expanded(
//             child: GridView.builder(
//               gridDelegate:
//                   SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
//               itemCount: _remoteRenderers.length,
//               itemBuilder: (context, index) {
//                 final renderer = _remoteRenderers.values.elementAt(index);
//                 return RTCVideoView(renderer);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
