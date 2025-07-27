// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({Key? key}) : super(key: key);

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  MediaStream? _localStream;
  RTCPeerConnection? _peerConnection;
  final TextEditingController _roomIdController = TextEditingController();
  bool _cameraEnabled = true;
  bool _callEnded = false;
  Duration _callDuration = Duration.zero;
  Timer? _callTimer;

  @override
  void initState() {
    super.initState();
    _initializeEverything();
  }

  Future<void> _initializeEverything() async {
    await _initRenderers();
    final permissionGranted = await _requestPermissions();
    if (permissionGranted) {
      await _openUserMedia();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera and Microphone permission denied")),
      );
    }
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();
    return statuses[Permission.camera]!.isGranted && statuses[Permission.microphone]!.isGranted;
  }

  Future<void> _openUserMedia() async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'video': {'facingMode': 'user'},
      'audio': true,
    });

    _localRenderer.srcObject = stream;
    setState(() {
      _localStream = stream;
    });
  }

  Future<void> _createRoom() async {
    final db = FirebaseFirestore.instance;
    final roomRef = db.collection('rooms').doc();
    _roomIdController.text = roomRef.id;

    _peerConnection = await _createPeerConnection();

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'video' && event.streams.isNotEmpty) {
        setState(() {
          _remoteRenderer.srcObject = event.streams[0];
        });
      }
    };

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    await roomRef.set({'offer': offer.toMap()});

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      roomRef.collection('callerCandidates').add(candidate.toMap());
    };

    roomRef.snapshots().listen((snapshot) async {
      final data = snapshot.data();
      if (data != null && data.containsKey('answer')) {
        final answer = data['answer'];
        final desc = RTCSessionDescription(answer['sdp'], answer['type']);
        await _peerConnection!.setRemoteDescription(desc);
      }
    });

    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          _peerConnection?.addCandidate(RTCIceCandidate(
            data?['candidate'],
            data?['sdpMid'],
            data?['sdpMLineIndex'],
          ));
        }
      }
    });

    _startCallTimer();
  }

  Future<void> _joinRoom() async {
    final roomId = _roomIdController.text.trim();
    if (roomId.isEmpty) return;

    final db = FirebaseFirestore.instance;
    final roomRef = db.collection('rooms').doc(roomId);
    final snapshot = await roomRef.get();

    if (!snapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Room not found")),
      );
      return;
    }

    _peerConnection = await _createPeerConnection();

    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.track.kind == 'video' && event.streams.isNotEmpty) {
        setState(() {
          _remoteRenderer.srcObject = event.streams[0];
        });
      }
    };

    final data = snapshot.data()!;
    final offer = data['offer'];
    await _peerConnection!.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    await roomRef.update({'answer': answer.toMap()});

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      roomRef.collection('calleeCandidates').add(candidate.toMap());
    };

    roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data();
          _peerConnection?.addCandidate(RTCIceCandidate(
            data?['candidate'],
            data?['sdpMid'],
            data?['sdpMLineIndex'],
          ));
        }
      }
    });

    _startCallTimer();
  }

  void _startCallTimer() {
    _callDuration = Duration.zero;
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration += const Duration(seconds: 1);
      });
    });
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final pc = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    return pc;
  }

  void _toggleCamera() {
    if (_localStream != null) {
      for (var track in _localStream!.getVideoTracks()) {
        track.enabled = !_cameraEnabled;
      }
      setState(() {
        _cameraEnabled = !_cameraEnabled;
      });
    }
  }

  Future<void> _endCall() async {
    _callTimer?.cancel();
    await _peerConnection?.close();
    await _peerConnection?.dispose();
    _peerConnection = null;

    if (_localStream != null) {
      for (var track in _localStream!.getTracks()) {
        track.stop();
      }
      await _localStream?.dispose();
      _localStream = null;
    }

    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    _roomIdController.clear();

    setState(() {
      _callEnded = true;
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.dispose();
    _localStream?.dispose();
    _roomIdController.dispose();
    super.dispose();
  }

  Widget _buildVideoView(String label, RTCVideoRenderer renderer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.getFont("Lato", fontWeight: FontWeight.w600, fontSize: 16)),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
            color: Colors.black,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: renderer.srcObject != null
                      ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                    child: RTCVideoView(renderer, mirror: label == "Local View"),
                  )
                      : Center(child: Text("Waiting for video...", style: GoogleFonts.getFont("Lato", color: Colors.white))),
                ),
              ),
              if (_callDuration.inSeconds > 0 && label == "Local View")
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${_callDuration.inMinutes.toString().padLeft(2, '0')}:${(_callDuration.inSeconds % 60).toString().padLeft(2, '0')}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_callEnded) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "You left the call",
            style: GoogleFonts.lato(fontSize: 24, color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("VideoCalls", style: GoogleFonts.getFont("Lato", fontSize: 25)),
            const SizedBox(width: 10),
            Image.asset("assets/images/communication.png", width: 30),
          ],
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: const Color(0xff09203f),
        titleTextStyle: GoogleFonts.getFont(
          "Lato",
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 15,
        ),
        toolbarHeight: 60,
        elevation: 10,
        shadowColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildVideoView("Local View", _localRenderer),
              _buildVideoView("Remote View", _remoteRenderer),
              TextField(
                controller: _roomIdController,
                decoration: InputDecoration(
                  labelText: "Room ID",
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45),
                  ),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: _roomIdController.text),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Room ID copied!")),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: _createRoom,
                    icon: const Icon(Icons.video_camera_front, color: Colors.white),
                    label: const Text("Create Room", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _joinRoom,
                    icon: Icon(Icons.group_add, color: Colors.blue.shade900),
                    label: Text("Join Room", style: TextStyle(color: Colors.blue.shade900)),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.blue.shade900),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: _toggleCamera,
                    icon: const Icon(Icons.videocam_off, color: Colors.white),
                    label: const Text("Toggle Camera", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _endCall,
                    icon: const Icon(Icons.call_end, color: Colors.white),
                    label: const Text("End Call", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}