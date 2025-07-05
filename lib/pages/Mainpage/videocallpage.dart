// lib/video_call_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class RootScaffold extends StatelessWidget {
  const RootScaffold({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: Colors.black,

    body: SafeArea(child: VideoCallScreen()),
  );
}

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});
  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  /* ─────────── renderers & controllers ─────────── */
  final _localRenderer  = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  final _createCtrl = TextEditingController();
  final _joinCtrl   = TextEditingController();

  MediaStream?       _localStream;
  RTCPeerConnection? _pc;
  MediaStreamTrack?  _videoTrack;

  CollectionReference? _callerCands;
  CollectionReference? _calleeCands;
  DocumentReference?   _roomDoc;

  final _db = FirebaseFirestore.instance;
  bool _camOn = true;
  bool _micOn = true;

  /* ─────────── lifecycle ─────────── */
  @override
  void initState() {
    super.initState();
    _initRenderers();
    _ensurePermissionsAndOpenCam();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _createCtrl.dispose();
    _joinCtrl.dispose();
    _pc?.dispose();
    _localStream?.dispose();
    super.dispose();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  /* ─────────── permissions & local camera ─────────── */
  Future<void> _ensurePermissionsAndOpenCam() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (statuses.values.any((s) => !s.isGranted)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera / Mic permission denied')),
        );
      }
      return;
    }
    _openLocalCam();
  }

  Future<void> _openLocalCam() async {
    try {
      final stream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {'facingMode': 'user'},
      });
      _videoTrack             = stream.getVideoTracks().first;
      _localRenderer.srcObject = stream;
      setState(() => _localStream = stream);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open camera: $e')),
        );
      }
    }
  }

  /* ─────────── toggle helpers ─────────── */
  Future<void> _toggleCam() async {
    if (_videoTrack == null) return;
    setState(() {
      _camOn = !_camOn;
      _videoTrack!.enabled = _camOn;
    });
  }

  Future<void> _switchCam() async {
    if (_videoTrack != null) await Helper.switchCamera(_videoTrack!);
  }

  /* ─────────── WebRTC core ─────────── */
  Future<void> _createPeerConnection() async {
    final pc = await createPeerConnection({
      'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}],
    });

    _localStream?.getTracks().forEach((t) => pc.addTrack(t, _localStream!));

    pc.onIceCandidate = (c) async {
      if (c == null) return;
      final data = {
        'candidate': c.candidate,
        'sdpMid': c.sdpMid,
        'sdpMLineIndex': c.sdpMLineIndex,
      };
      if (_callerCands != null) await _callerCands!.add(data);
      if (_calleeCands != null) await _calleeCands!.add(data);
    };

    pc.onTrack = (e) async {
      if (e.streams.isNotEmpty) {
        _remoteRenderer.srcObject = e.streams[0];
      } else {
        final temp = await createLocalMediaStream('remote');
        temp.addTrack(e.track);
        _remoteRenderer.srcObject = temp;
      }
      setState(() {});
    };

    _pc = pc;
  }

  /* ─────────── create room ─────────── */
  Future<void> _createRoom() async {
    final room = _db.collection('rooms').doc();
    _roomDoc     = room;
    _callerCands = room.collection('callerCandidates');

    await _createPeerConnection();

    _createCtrl.text = room.id;            // show ID immediately
    final offer = await _pc!.createOffer();
    await _pc!.setLocalDescription(offer);
    await room.set({'offer': {'type': offer.type, 'sdp': offer.sdp}});

    // listen for answer
    room.snapshots().listen((snap) async {
      final data = snap.data();
      if (data?['answer'] == null) return;
      final ans = data!['answer'];
      await _pc!.setRemoteDescription(
          RTCSessionDescription(ans['sdp'], ans['type']));
    });

    // callee ICE
    room.collection('calleeCandidates').snapshots().listen((s) {
      for (var c in s.docChanges) {
        if (c.type != DocumentChangeType.added) continue;
        final d = c.doc.data()!;
        _pc!.addCandidate(
            RTCIceCandidate(d['candidate'], d['sdpMid'], d['sdpMLineIndex']));
      }
    });
  }

  /* ─────────── join room ─────────── */
  Future<void> _joinRoom() async {
    final id = _joinCtrl.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a Room ID first')));
      return;
    }

    final room = _db.collection('rooms').doc(id);
    final snap = await room.get();
    if (!snap.exists || (snap.data()?['offer'] == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room not found / no offer')));
      return;
    }

    _roomDoc    = room;
    _calleeCands = room.collection('calleeCandidates');
    await _createPeerConnection();

    final offer = snap.data()!['offer'];
    await _pc!.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']));

    final answer = await _pc!.createAnswer();
    await _pc!.setLocalDescription(answer);
    await room.update({'answer': {'type': answer.type, 'sdp': answer.sdp}});

    room.collection('callerCandidates').snapshots().listen((s) {
      for (var c in s.docChanges) {
        if (c.type != DocumentChangeType.added) continue;
        final d = c.doc.data()!;
        _pc!.addCandidate(
            RTCIceCandidate(d['candidate'], d['sdpMid'], d['sdpMLineIndex']));
      }
    });
  }

  /* ─────────── end call ─────────── */
  void _endCall() {
    _localRenderer.srcObject  = null;
    _remoteRenderer.srcObject = null;
    _localStream?.getTracks().forEach((t) => t.stop());
    _pc?.close();

    setState(() {
      _pc           = null;
      _callerCands  = null;
      _calleeCands  = null;
      _roomDoc      = null;
      _createCtrl.clear();
      _joinCtrl.clear();
      _camOn = true;
      _micOn = true;
    });

    _openLocalCam();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Call ended')));
  }

  /* ─────────── UI helpers ─────────── */
  InputDecoration _field(String lbl) => InputDecoration(
    labelText : lbl,
    labelStyle: const TextStyle(color: Colors.black),
    filled    : true,
    fillColor : Colors.white,
    border    : OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );

  Widget _iconBtn(IconData i, VoidCallback onTap, {Color? bg}) => Ink(
    decoration:
    ShapeDecoration(color: bg ?? Colors.blueGrey.shade700, shape: const CircleBorder()),
    child: IconButton(icon: Icon(i, color: Colors.white), onPressed: onTap, splashRadius: 24),

  );






  /* ─────────── build ─────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Video Calls",style: GoogleFonts.getFont("Lato",fontSize: 25),),

            SizedBox(width:10,),
            Image.asset("assets/images/communication.png",width: 30,),

          ],
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Color(0xff09203f),
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
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Section ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _createCtrl,
                        readOnly: true,
                        decoration: _field('Room ID (generated)'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.white),
                      onPressed: () {
                        if (_createCtrl.text.isEmpty) return;
                        _joinCtrl.text = _createCtrl.text;
                        Clipboard.setData(
                            ClipboardData(text: _createCtrl.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ID copied')));
                      },
                    ),
                    const SizedBox(width: 6),

                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _joinCtrl,
                        decoration: _field('Enter Room ID'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 6),

                  ]),
                ],
              ),
            ),

            // ── Video Panes ───────────────────────────────────────────────────
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _remoteRenderer.srcObject == null
                          ? const Center(
                          child: Text('Waiting for remote…',
                              style: TextStyle(color: Colors.white70)))
                          : RTCVideoView(_remoteRenderer,
                          objectFit: RTCVideoViewObjectFit
                              .RTCVideoViewObjectFitCover),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _localRenderer.srcObject == null
                          ? const Center(
                          child: Text('Opening camera…',
                              style: TextStyle(color: Colors.white70)))
                          : RTCVideoView(_localRenderer,
                          mirror: true,
                          objectFit: RTCVideoViewObjectFit
                              .RTCVideoViewObjectFitCover),
                    ),
                  ),
                ],
              ),
            ),

            // ── Control Bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _iconBtn(
                      _camOn ? Icons.videocam : Icons.videocam_off, _toggleCam),
                  _iconBtn(Icons.cameraswitch, _switchCam),
                  _iconBtn(_micOn ? Icons.mic : Icons.mic_off, () {
                    setState(() {
                      _micOn = !_micOn;
                      _localStream?.getAudioTracks().forEach(
                              (t) => t.enabled = _micOn);
                    });
                  }),
                  _iconBtn(Icons.call_end, _endCall, bg: Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
