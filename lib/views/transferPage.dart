//import 'package:camera/camera.dart';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../globals.dart';
import '../services/transfer.dart';
import 'package:path/path.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ClassifierPage extends StatefulWidget {
  // final CameraDescription camera;
  //final ImagePicker camera;
  const ClassifierPage({
    Key? key,
  }) : super(key: key);

  @override
  _ClassifierPageState createState() => _ClassifierPageState();
}

class _ClassifierPageState extends State<ClassifierPage> {
  late Transfer transfer;
//  CameraController _controller;
  final ImagePicker picker = ImagePicker();
  //Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    Interpreter? _inter;
    transfer = Transfer(_inter);
    // _controller = CameraController(
    //   widget.camera,
    //   ResolutionPreset.medium,
    //   enableAudio: false,
    // );

    // _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    //  _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(
    //     backgroundColor: Colors.transparent,
    //     elevation: 0.0,
    //     title: Text(
    //       'MIR-Net TF Lite',
    //       style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    //     ),
    // actions: [
    //   Padding(
    //     padding:
    //         const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    //     child: Image.asset('assets/images/tf-logo.jpg'),
    //   )
    // ],
    //),
    // body:
    // return FutureBuilder<void>(
    //   future: _initializeControllerFuture,
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.done) {
    return Column(
      children: [
        // Expanded(
        //   child: Container(
        //     padding: const EdgeInsets.all(10),
        //     child: ClipRRect(
        //       borderRadius: BorderRadius.circular(20),
        //       child: Image.file(path),
        //       //child: CameraPreview(_controller),
        //     ),
        //   ),
        // ),
        Container(
          height: 200,
          child: IconButton(
            iconSize: 60,
            onPressed: () {
              _runModel(context);
            },
            icon: Icon(Icons.camera),
          ),
        ),
        _loading ? CircularProgressIndicator() : Container(),
      ],
    );
    // } else {
    //   return Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }
  }

  // );
  // }

  bool _loading = false;
  void _runModel(context) async {
    setState(() {
      _loading = true;
    });
    //await _initializeControllerFuture;
    // final path = join(
    //   (await getTemporaryDirectory()).path,
    //   '${DateTime.now()}.png',
    // );
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    // await _controller.takePicture(path);
    final path = image?.path;
    var loadImage;
    var loadResult;
    if (path != null) {
      loadImage = await transfer.loadImage(path);
      loadResult = await transfer.runModel(loadImage!);
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enhanced Image",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Image.memory(
                   Uint8List.fromList(img.encodeJpg(loadResult)),
                    //  img.encodeJpg(loadResult),
                    height: 400,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    setState(() {
      _loading = false;
    });
  }
}
