import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtcvideocall/screens/gptScreen.dart';
import 'package:webrtcvideocall/screens/homeScreenmulti.dart';
import 'package:webrtcvideocall/screens/homescreen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: HomeScreenV1(),
        ),
      ),
    );
  }
}

// class VideoCallPage extends StatefulWidget {
//   @override
//   _VideoCallPageState createState() => _VideoCallPageState();
// }

// class _VideoCallPageState extends State<VideoCallPage> {
//   late IO.Socket socket;
//   final List<RTCPeerConnection> peerConnections = [];
//   final Map<String, MediaStream> remoteStreams = {};
//   final String roomId = "your_room_id"; // Use a unique room ID
//   MediaStream? localStream;

//   @override
//   void initState() {
//     super.initState();
//     _initSocket();
//     _createLocalStream();
//   }

//   void _initSocket() {
//     socket = IO.io('http://your_signaling_server:3000', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': false,
//     });

//     socket.connect();

//     socket.onConnect((_) {
//       print('Connected to signaling server');
//       socket.emit('join', roomId);
//     });

//     socket.on('user-joined', (data) {
//       _createPeerConnection(data['userId']);
//     });

//     socket.on('ice-candidate', (data) {
//       _addIceCandidate(data);
//     });

//     socket.on('offer', (data) {
//       _handleOffer(data);
//     });

//     socket.on('answer', (data) {
//       _handleAnswer(data);
//     });
//   }

//   Future<void> _createLocalStream() async {
//     localStream = await navigator.mediaDevices.getUserMedia({
//       'audio': true,
//       'video': true,
//     });

//     // Broadcast local stream to all connected peers
//     socket.emit('stream', {'roomId': roomId, 'stream': localStream});
//   }

//   Future<void> _createPeerConnection(String userId) async {
//     RTCPeerConnection pc = await createPeerConnection({
//       'iceServers': [
//         {'urls': 'stun:stun.l.google.com:19302'}
//       ]
//     });

//     peerConnections.add(pc);

//     // Add local stream to the peer connection
//     pc.addStream(localStream!);

//     pc.onIceCandidate = (RTCIceCandidate candidate) {
//       socket.emit('ice-candidate', {
//         'roomId': roomId,
//         'candidate': candidate.toMap(),
//         'userId': userId,
//       });
//     };

//     pc.onTrack = (RTCTrackEvent event) {
//       setState(() {
//         remoteStreams[userId] = event.streams[0];
//       });
//     };

//     // Create offer for new peer connections
//     if (peerConnections.length > 1) {
//       var offer = await pc.createOffer();
//       await pc.setLocalDescription(offer);
//       socket.emit('offer', {
//         'roomId': roomId,
//         'offer': offer.toMap(),
//         'userId': userId,
//       });
//     }
//   }

//   Future<void> _handleOffer(data) async {
//     RTCPeerConnection pc = await createPeerConnection({
//       'iceServers': [
//         {'urls': 'stun:stun.l.google.com:19302'}
//       ]
//     });

//     pc.addStream(localStream!);
//     await pc.setRemoteDescription(RTCSessionDescription(data['offer']['sdp'], data['offer']['type']));

//     var answer = await pc.createAnswer();
//     await pc.setLocalDescription(answer);
//     socket.emit('answer', {
//       'roomId': roomId,
//       'answer': answer.toMap(),
//       'userId': data['userId'],
//     });
//   }

//   Future<void> _handleAnswer(data) async {
//     var pc = peerConnections.firstWhere((pc) => pc. == data['userId']);
//     await pc.setRemoteDescription(RTCSessionDescription(data['answer']['sdp'], data['answer']['type']));
//   }

//   void _addIceCandidate(data) {
//     var pc = peerConnections.firstWhere((pc) => pc.peerConnectionId == data['userId']);
//     pc.addIceCandidate(RTCIceCandidate(data['candidate']['candidate'], data['candidate']['sdpMid'], data['candidate']['sdpMLineIndex']));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Multi-user Video Call")),
//       body: Stack(
//         children: [
//           // Render local video
//           RTCVideoView(localStream, mirror: true),
//           // Render remote video streams
//           ...remoteStreams.entries.map((entry) {
//             return RTCVideoView(entry.value);
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     socket.dispose();
//     localStream?.dispose();
//     peerConnections.forEach((pc) => pc.dispose());
//     super.dispose();
//   }
// }

