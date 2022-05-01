import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sohbet_muhabbet/controller/reklam_controller.dart';
import 'package:wakelock/wakelock.dart';
import './call.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final _channelController = TextEditingController();
  bool _validateError = false;
  ClientRole? _role = ClientRole.Broadcaster;
  final reklam = ReklamController();

  @override
  void initState() {
    reklam.myBanner.load();
    reklam.gecisliReklamim;
    super.initState();
  }

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sohbet Muhabbet Index Page"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.network("https://tinyurl.com/2p889y4k"),
              const SizedBox(height: 20),
              TextField(
                controller: _channelController,
                decoration: InputDecoration(
                  errorText:
                      _validateError ? "Lütfen kanal isminizi yazın" : null,
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(width: 1),
                  ),
                  hintText: "Kanal ismi",
                ),
              ),
              RadioListTile(
                title: const Text("Yayıncı"),
                onChanged: (ClientRole? value) {
                  setState(() {
                    _role = value;
                  });
                },
                value: ClientRole.Broadcaster,
                groupValue: _role,
              ),
              RadioListTile(
                title: const Text("Dinleyici"),
                onChanged: (ClientRole? value) {
                  setState(() {
                    _role = value;
                  });
                },
                value: ClientRole.Audience,
                groupValue: _role,
              ),
              ElevatedButton(
                onPressed: onJoin,
                child: const Text("Join Yap"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        alignment: Alignment.center,
        height: reklam.myBanner.size.height.toDouble(),
        width: reklam.myBanner.size.width.toDouble(),
        color: Colors.pink,
        child: AdWidget(
          ad: reklam.myBanner,
        ),
      ),
    );
  }

  Future<void> onJoin() async{
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
      Wakelock.enable();
    });
    reklam.gecisliReklamim;
    if(_channelController.text.isNotEmpty){
      await _handleCameraAndMic(Permission.camera);
      await _handleCameraAndMic(Permission.microphone);
      await Navigator.push(context, MaterialPageRoute(builder: (context) =>
      CallPage(
        channelName: _channelController.text,
        role: _role,
      )));
    }
  }


  Future<void> _handleCameraAndMic(Permission permission) async{
    final status = await permission.request();
    log(status.toString());
  }

}
