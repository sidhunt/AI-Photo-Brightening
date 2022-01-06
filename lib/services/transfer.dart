import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import '../globals.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class Transfer {
  Interpreter? _interpreter;

  Transfer(
    this._interpreter,
  ) {
    _loadModel();
  }

  void _loadModel() async {
    var interpreterOptions;
    if (Platform.isAndroid) {
      // Android GpuDelegateV2
      final gpuDelegateV2 = GpuDelegateV2(options: GpuDelegateOptionsV2());

      interpreterOptions = InterpreterOptions()..addDelegate(gpuDelegateV2);
    } else if (Platform.isIOS) {
      // iOS Metal Delegate (GpuDelegate)
      final gpuDelegate = GpuDelegate(
        options: GpuDelegateOptions(),
      );
      interpreterOptions = InterpreterOptions()..addDelegate(gpuDelegate);
    }
    //File f1 = await App.getFile(App.tflite_model);
    _interpreter =  Interpreter.fromFile(File(App.tflite_model),
        options: interpreterOptions);

    // await Interpreter.fromAsset("lite-model_mirnet-fixed_integer_1.tflite",
    //     options: interpreterOptions);

    var inputShape = _interpreter?.getInputTensor(0).shape;
    var outputShape = _interpreter?.getOutputTensor(0).shape;
    print('Load Model - $inputShape / $outputShape');
  }

  Future<img.Image?> loadImage(String imagePath) async {
    var originData = File(imagePath).readAsBytesSync();
    var originImage = img.decodeImage(originData);
    print("Loading Image");
    return originImage;
  }

  Future<dynamic> runModel(img.Image loadImage) async {
    var modelImage = img.copyResize(loadImage, width: 400, height: 400);
    var modelInput = imageToByteListFloat32(modelImage, 400);
    // bright_image 1 400 400 3
    var outputsForPrediction = [
      List.generate(
        400,
        (index) => List.generate(
          400,
          (index) => List.generate(3, (index) => 0.0),
        ),
      ),
    ];
    _interpreter?.run(modelInput.buffer, outputsForPrediction);
    var outputImage = _convertArrayToImage(outputsForPrediction, 400);
    return outputImage;
  }

  //Convert Image to Float32
  Float32List imageToByteListFloat32(img.Image image, int inputSize) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);

        buffer[pixelIndex++] = (img.getRed(pixel) - 0) / 255;
        buffer[pixelIndex++] = (img.getGreen(pixel) - 0) / 255;
        buffer[pixelIndex++] = (img.getBlue(pixel) - 0) / 255;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  //Conversion array to Image
  img.Image _convertArrayToImage(
      List<List<List<List<double>>>> imageArray, int inputSize) {
    img.Image image = img.Image.rgb(inputSize, inputSize);
    for (var x = 0; x < imageArray[0].length; x++) {
      for (var y = 0; y < imageArray[0][0].length; y++) {
        var r = (imageArray[0][x][y][0] * 255).toInt();
        var g = (imageArray[0][x][y][1] * 255).toInt();
        var b = (imageArray[0][x][y][2] * 255).toInt();
        image.setPixelRgba(x, y, r, g, b);
      }
    }
    return image;
  }
}

//   Transfer copyWith({
//     Interpreter? interpreter,
//   }) {
//     return Transfer(
//       _interpreter,  ?? this._interpreter,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       '_interpreter': _interpreter.toMap(),
//     };
//   }

//   factory Transfer.fromMap(Map<String, dynamic> map) {
//     return Transfer(
//       Interpreter.fromMap(map['_interpreter']),
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory Transfer.fromJson(String source) => Transfer.fromMap(json.decode(source));

//   @override
//   String toString() => 'Transfer(_interpreter: $_interpreter)';

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;
  
//     return other is Transfer &&
//       other._interpreter == _interpreter;
//   }

//   @override
//   int get hashCode => _interpreter.hashCode;
// }
