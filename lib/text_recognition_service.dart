// text_recognition_service.dart
import 'package:google_ml_kit/google_ml_kit.dart';

class TextRecognitionService {
  final TextRecognizer _textRecognizer;

  TextRecognitionService() : _textRecognizer = GoogleMlKit.vision.textRecognizer();

  Future<String> recognizeText(String imagePath) async {
    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    // Concatenate all recognized text into a single string.
    String resultText = '';
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        resultText += '${line.text}\n';
      }
    }

    return resultText;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
