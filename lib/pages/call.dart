import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import '../utils/settings.dart';
import 'dart:async';

class CallPage extends StatefulWidget {
  final String? channelName;
  final ClientRole? role;

  const CallPage({
    Key? key,
    this.channelName,
    this.role,
  }) : super(key: key);

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool viewPanel = false;
  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }

  Future<void> initialize() async {
    if (appId.isEmpty) {
      setState(() {
        _infoStrings.add("AppId missing yani boş, Lütfen Ap Id yenileyin");
        _infoStrings.add("Sohbet başlatılamadı");
      });
      return;
    }

    /// Burası Yayını başlatan kısım
    _engine = await RtcEngine.create(appId);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role!);

    _addSohbetHandlers();

    /// Sohbet Ekranının çözünürlüğünün olduğu yer
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(
        width: 2560, height: 1440);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(token, widget.channelName!, null, 0);
  }

  void _addSohbetHandlers() {
    _engine.setEventHandler(
        RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = "Hata Oldu : $code";
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) {
      setState(() {
        final info = "Join Kanal: $channel, uid: $uid";
        _infoStrings.add(info);
      });
    }, leaveChannel: (stats) {
      setState(() {
        _infoStrings.add("Kanaldan Ayrıldı");
        _users.clear();
      });
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = "Kullanıcı katıldı: $uid";
        _infoStrings.add(info);
        _users.add(uid);
      });
    }, userOffline: (uid, elapsed) {
      setState(() {
        final info = "Kullanıcı Çevrimdışı $uid";
        _infoStrings.add(info);
        _users.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = "İlk Remote Video: $uid ${width} x $height";
        _infoStrings.add(info);
      });
    }));
  }

  /// Yayıncının videosunun belirlendiği kod
  Widget _viewRows() {
    final List<StatefulWidget> list = [];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(const rtc_local_view.SurfaceView());
    }
    for (var uid in _users) {
      list.add(rtc_remote_view.SurfaceView(
        uid: uid,
        channelId: widget.channelName!,
      ));
    }
    final views = list;
    return Column(
      children: List.generate(
          views.length,
          (index) => Expanded(
                child: views[index],
              )),
    );
  }

  /// Ekranın altındaki butonlar
  Widget _toolBar() {
    if (widget.role == ClientRole.Audience) return const SizedBox();
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            onPressed: () {
              setState(() {
                muted = !muted;
              });
              _engine.muteLocalAudioStream(muted);
            },
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20,
            ),
            shape: const CircleBorder(),
            elevation: 2,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12),
          ),
          RawMaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35,
            ),
            shape: const CircleBorder(),
            elevation: 2,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15),
          ),
          RawMaterialButton(
            onPressed: () {
              _engine.switchCamera();
            },
            child: const Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20,
            ),
            shape: const CircleBorder(),
            elevation: 2,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12),
          ),
        ],
      ),
    );
  }

  /// Bilgilerin yazılacağı panel
  Widget _panel() {
    return Visibility(
      visible: viewPanel,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: ListView.builder(
              reverse: true,
              itemCount: _infoStrings.length,
              itemBuilder: (BuildContext context, int index) {
                if (_infoStrings.isEmpty) {
                  return const Text("null");
                }
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(_infoStrings[index],
                          style: const TextStyle(
                            color: Colors.blueGrey
                          ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sohbet Muhabbet Call Page"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            setState(() {
              viewPanel = !viewPanel;
            });
          },
          icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            _panel(),
            _toolBar(),
          ],
        ),
      ),
    );
  }
}
