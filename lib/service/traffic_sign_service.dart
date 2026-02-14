import 'dart:typed_data';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TrafficSignService {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    final options = InterpreterOptions()..threads = 4;

    _interpreter = await Interpreter.fromAsset(
      'assets/model/model.tflite',
      options: options,
    );
  }

  Future<List<double>> predict(Uint8List imageBytes) async {
    return Future(() {
      // Decode image
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception("Image decoding failed");
      }

      // Resize to model input size
      img.Image resized = img.copyResize(
        image,
        width: 32,
        height: 32,
      );

      // Prepare input tensor (1, 32, 32, 3)
      final input = Float32List(1 * 32 * 32 * 3);
      int index = 0;

      for (int y = 0; y < 32; y++) {
        for (int x = 0; x < 32; x++) {
          final pixel = resized.getPixel(x, y);

          input[index++] = pixel.r.toDouble();
          input[index++] = pixel.g.toDouble();
          input[index++] = pixel.b.toDouble();


        }
      }

      final inputTensor = input.reshape([1, 32, 32, 3]);

      final output = List.filled(43, 0.0).reshape([1, 43]);

      _interpreter.run(inputTensor, output);

      return List<double>.from(output[0]);
    });
  }

  void close() {
    _interpreter.close();
  }
}
