import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef void StreamStateCallback(MediaStream stream);

class Signaling {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  StreamStateCallback? onAddRemoteStream;

  final Map<String, dynamic> configuration = {
    'iceServers': [
      // STUN
      {
        'urls': 'stun:stun.relay.metered.ca:80',
      },

      // TURN UDP
      {
        'urls': 'turn:global.relay.metered.ca:80',
        'username': '273fe7dbf04b56d09d97c590',
        'credential': 'Eb5gC0BrTVvnaiYm',
      },

      // TURN TCP
      {
        'urls': 'turn:global.relay.metered.ca:80?transport=tcp',
        'username': '273fe7dbf04b56d09d97c590',
        'credential': 'Eb5gC0BrTVvnaiYm',
      },

      // TURN UDP 443
      {
        'urls': 'turn:global.relay.metered.ca:443',
        'username': '273fe7dbf04b56d09d97c590',
        'credential': 'Eb5gC0BrTVvnaiYm',
      },

      // TURN TLS (BEST for strict networks)
      {
        'urls': 'turns:global.relay.metered.ca:443?transport=tcp',
        'username': '273fe7dbf04b56d09d97c590',
        'credential': 'Eb5gC0BrTVvnaiYm',
      },
    ],
  };



  // ✅ Open Camera & Mic
  Future<MediaStream?> openUserMedia(RTCVideoRenderer localRenderer, RTCVideoRenderer remoteRenderer) async {
    try {
      final Map<String, dynamic> constraints = {
        "audio": true,
        "video": false, // ✅ Video OFF
      };


      MediaStream stream = await navigator.mediaDevices.getUserMedia(constraints);
      localStream = stream;
      localRenderer.srcObject = stream;
      return stream;

    } catch (e) {
      print("❌ Error opening user media: $e");
      return null;
    }
  }




  final Map<String, dynamic> sdpConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  // ✅ Join Room
  Future<void> joinRoom(String roomId, RTCVideoRenderer remoteRenderer) async {
    DocumentReference roomRef = db.collection('safe_space/video_calls').doc(roomId);
    var roomSnapshot = await roomRef.get();

    if (roomSnapshot.exists) {
      peerConnection = await createPeerConnection(configuration);
      _registerPeerConnectionListeners();

      localStream?.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream!);
      });

      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
        if (candidate != null) {
          calleeCandidatesCollection.add(candidate.toMap());
        }
      };


      var data = roomSnapshot.data() as Map<String, dynamic>;
      var offer = data['offer'];

      await peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      var answer = await peerConnection!.createAnswer(sdpConstraints);
      await peerConnection!.setLocalDescription(answer);

      await roomRef.update({"answer": answer.toMap(), "status": "ongoing"});


      roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        for (var change in snapshot.docChanges) {
          var data = change.doc.data() as Map<String, dynamic>;
          peerConnection!.addCandidate(
            RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']),
          );
        }
      });
    }
  }

  // ✅ End Call & Cleanup
  Future<void> hangUp(RTCVideoRenderer localVideo) async {
    print("📴 Hanging up...");

    try {
      // ✅ Stop and release all media tracks from localStream
      if (localStream != null) {
        for (var track in localStream!.getTracks()) {
          print("🛑 Stopping local track: ${track.kind}");
          track.stop();
        }
        await localStream!.dispose();
        localStream = null;
      }

      // ✅ Stop and release all media tracks from remoteStream
      if (remoteStream != null) {
        for (var track in remoteStream!.getTracks()) {
          print("🛑 Stopping remote track: ${track.kind}");
          track.stop();
        }
        await remoteStream!.dispose();
        remoteStream = null;
      }

      // ✅ Close and clear PeerConnection
      if (peerConnection != null) {
        print("🔌 Closing peer connection...");
        await peerConnection!.close();
        peerConnection = null;
      }

      // ✅ Clear video renderers before disposal
      if (localVideo.srcObject != null) {
        print("🛑 Clearing local video renderer...");
        localVideo.srcObject = null;
      }

      // ✅ Dispose video renderer safely
      print("🗑️ Disposing local video renderer...");
      await localVideo.dispose();

      // ✅ Forcefully revoke camera & microphone permissions
      print("🚨 Revoking camera & microphone access...");
      await navigator.mediaDevices.getUserMedia({'video': true, 'audio': true})
          .then((stream) {
        stream.getTracks().forEach((track) {
          track.stop();
        });
      }).catchError((error) {
        print("⚠️ Error revoking media access: $error");
      });

      print("🔄 Camera & Microphone fully released");

      print("🔥 Cleaning up Firestore session...");
    } catch (e) {
      print("❌ Error while hanging up: $e");
    }
  }






  void _registerPeerConnectionListeners() {
    peerConnection?.onTrack = (RTCTrackEvent event) {
      print("🎥 Received remote track: ${event.track.kind}");
      if (event.streams.isEmpty) return;

      final stream = event.streams.first;

      if (remoteStream?.id != stream.id) {
        remoteStream = stream;
        print("🎧 New remote stream: ${stream.id}");
        
        // ✅ ENABLE AUDIO TRACKS
        for (final audioTrack in stream.getAudioTracks()) {
          print("🔊 Audio track found and enabled: ${audioTrack.id}");
          audioTrack.enabled = true;
        }

        onAddRemoteStream?.call(stream);
      }
    };

    peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      print('🌐 ICE Connection State: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('🔌 Connection State: $state');
    };
  }


}
