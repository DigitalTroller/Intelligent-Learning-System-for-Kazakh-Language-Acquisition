import 'package:tflite/tflite.dart';

class TFLiteService {
  Future<String?> predict(String imagePath) async {
    await Tflite.loadModel(
      model: "assets/cloth_model.tflite",
      labels: "assets/labels.txt",
    );
    var recognitions = await Tflite.runModelOnImage(path: imagePath);
    Tflite.close();
    if (recognitions!.isNotEmpty) {
      var result = recognitions.first;
      String label = result['label'].split(' ').last;
      double confidence = result['confidence'] * 100;
      return "$label ${confidence.toStringAsFixed(1)}%";
    }
    return null;
  }
}
