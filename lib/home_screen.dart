import 'package:flutter/material.dart';
import 'package:google_translator/google_translator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'tflite_service.dart';
import 'text_recognition_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _recognitionResult; // Store TensorFlow Lite prediction result
  String? _recognizedText;
  String? _translatedText;
  final TextRecognitionService _textRecognitionService = TextRecognitionService();
  final TFLiteService _tfliteService = TFLiteService(); // Initialize TensorFlow Lite service

  @override
  void dispose() {
    _textRecognitionService.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> pickImage(ImageSource source, {bool forTextRecognition = false}) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _image = image;
      });
      if (forTextRecognition) {
        _selectedIndex = 2; // Switch to the Word tab
        recognizeAndTranslateText(image.path);
      } else {
        _selectedIndex = 1; // Switch to the Photo tab
        predictImage(image.path); // Predict image using TensorFlow Lite
      }
    }
  }

  Future<void> predictImage(String imagePath) async {
    final result = await _tfliteService.predict(imagePath);
    setState(() {
      _recognitionResult = result; // Update UI with the prediction result
    });
  }

  // Combines text recognition and translation
  Future<void> recognizeAndTranslateText(String imagePath) async {
    final resultText = await _textRecognitionService.recognizeText(imagePath);
    if (resultText != null && resultText.isNotEmpty) {
      _translatedText = Text("$resultText").translate() as String?; // Use recognized text
      setState(() {
        _recognizedText = resultText;
      });
    }
  }


  Widget _buildPhotoScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_image != null)
          Expanded(
            child: Image.file(File(_image!.path)),
          ),
        if (_recognitionResult != null) // Display prediction result if available
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Prediction: $_recognitionResult"),
          ),
        TextButton(
          onPressed: () => pickImage(ImageSource.camera),
          child: Text('Capture Image'),
        ),
        TextButton(
          onPressed: () => pickImage(ImageSource.gallery),
          child: Text('Select from Gallery'),
        ),
      ],
    );
  }

  Widget _buildWordScreen() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_recognizedText != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Recognized Text: $_recognizedText"),
            ),
          if (_translatedText != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Translated text: $_translatedText"),
            ),
          TextButton(
            onPressed: () => pickImage(ImageSource.camera, forTextRecognition: true),
            child: Text('Capture Image for Text Recognition'),
          ),
          TextButton(
            onPressed: () => pickImage(ImageSource.gallery, forTextRecognition: true),
            child: Text('Select Image for Text Recognition'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      Text('Main Screen'),
      _buildPhotoScreen(),
      _buildWordScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Instrument Recognition'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Main',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Photo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields),
            label: 'Word',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
