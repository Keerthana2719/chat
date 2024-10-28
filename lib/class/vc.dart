// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class Vc extends StatefulWidget {
//   final String selectedUsername;
//   Vc({super.key, required this.selectedUsername});
//
//   @override
//   State<Vc> createState() => _VcState();
// }
//
// class _VcState extends State<Vc> {
//   int? _remoteUid;
//   bool _localUserJoined = false;
//   late RtcEngine _engine;
//   bool _muted = false;
//   bool _cameraOff = false;
//
//   @override
//   void initState() {
//     super.initState();
//     initAgora();
//   }
//
//   Future<void> initAgora() async {
//     // retrieve permissions
//     await [Permission.microphone, Permission.camera].request();
//
//     //create the engine
//     _engine = createAgoraRtcEngine();
//     await _engine.initialize(const RtcEngineContext(
//       appId: "5ed65e14673e4c4db00b062bb55c0517",
//       channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
//     ));
//
//     _engine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           debugPrint("local user ${connection.localUid} joined");
//           setState(() {
//             _localUserJoined = true;
//           });
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           debugPrint("remote user $remoteUid joined");
//           setState(() {
//             _remoteUid = remoteUid;
//           });
//         },
//         onUserOffline: (RtcConnection connection, int remoteUid,
//             UserOfflineReasonType reason) {
//           debugPrint("remote user $remoteUid left channel");
//           setState(() {
//             _remoteUid = null;
//           });
//         },
//         onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
//           debugPrint(
//               '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
//         },
//       ),
//     );
//
//     await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//     await _engine.enableVideo();
//     await _engine.startPreview();
//
//     await _engine.joinChannel(
//       token: "007eJxTYDB+eIHp1RKe1Nxj0a/uHFv1I/1S0zM/vTiztnUrP33yiIpRYDBNTTEzTTU0MTM3TjVJNklJMjBIMjAzSkoyNU02MDU09+bhS28IZGRYFSLHysgAgSA+O0NaTmlJSWoRAwMASg0hdQ==",
//       channelId: "flutter",
//       uid: 0,
//       options: const ChannelMediaOptions(),
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//
//     _dispose();
//   }
//
//   Future<void> _dispose() async {
//     await _engine.leaveChannel();
//     await _engine.release();
//   }
//
//   void _onToggleMute() {
//     setState(() {
//       _muted = !_muted;
//     });
//     _engine.muteLocalAudioStream(_muted);
//   }
//
//   void _onToggleCamera() {
//     _engine.switchCamera(); // Switch between front and back cameras
//     setState(() {
//       _cameraOff = !_cameraOff;
//     });
//     _engine.muteLocalVideoStream(_cameraOff);
//   }
//
//   void _onEndCall() {
//     _dispose();
//     Navigator.pop(context);
//   }
//
//   // Create UI with local view and remote view
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//       ),
//       body: Stack(
//         children: [
//           Center(
//             child: _remoteVideo(),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: Align(
//               alignment: Alignment.topLeft,
//               child: SizedBox(
//                 width: 100,
//                 height: 150,
//                 child: Center(
//                   child: _localUserJoined
//                       ? AgoraVideoView(
//                     controller: VideoViewController(
//                       rtcEngine: _engine,
//                       canvas: const VideoCanvas(uid: 0),
//                     ),
//                   )
//                       : const CircularProgressIndicator(),
//                 ),
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(vertical: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   IconButton(
//                     icon: Icon(
//                       _muted ? Icons.mic_off : Icons.mic,
//                       color: _muted ? Colors.red : Colors.black,
//                     ),
//                     onPressed: _onToggleMute,
//                   ),
//                   IconButton(
//                     icon: const Icon(
//                       Icons.call_end,
//                       color: Colors.redAccent,
//                     ),
//                     onPressed: _onEndCall,
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       _cameraOff
//                           ? Icons.camera_alt
//                           : Icons.camera_alt_outlined,
//                       color: _cameraOff ? Colors.red : Colors.black,
//                     ),
//                     onPressed: _onToggleCamera,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   // Display remote user's video
//   Widget _remoteVideo() {
//     if (_remoteUid != null) {
//       return AgoraVideoView(
//         controller: VideoViewController.remote(
//           rtcEngine: _engine,
//           canvas: VideoCanvas(uid: _remoteUid),
//           connection: const RtcConnection(channelId: "flutter"),
//         ),
//       );
//     } else {
//       return const Text(
//         'Please wait for remote user to join',
//         textAlign: TextAlign.center,
//       );
//     }
//   }
// }