import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_billing/widgets/button.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';

class MeterDetectionScreen extends StatefulWidget {
  const MeterDetectionScreen({super.key});

  @override
  State<MeterDetectionScreen> createState() => _MeterDetectionScreenState();
}

class _MeterDetectionScreenState extends State<MeterDetectionScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  late Interpreter _interpreter;
  late TensorImage _tensorImage;
  // ignore: unused_field
  late List<String> _labels;
  String _meterDetectionResult = "";
  int _secondsLeft = 15; // Timer starts from 15 seconds
  Timer? _timer; // Timer variable
  bool timeEnd = false;
  bool showButton = true;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _startTimer(); // Start countdown when screen opens
    //captureImage(); // Automatically open the camera
  }

  /// Start a 15-second countdown timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer?.cancel(); // Stop timer
        //Navigator.of(context).pushReplacementNamed('/dashboard'); // Redirect to dashboard
        setState(() {
          timeEnd = true;
        });
      }
    });
  }

  /// Load TFLite Model
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset("assets/model.tflite");
      _labels = await FileUtil.loadLabels("assets/labels.txt");
      print("Model and Labels Loaded Successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  /// Capture Image
  Future<void> captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _timer?.cancel(); // Stop the timer if image is captured
      setState(() {
        showButton = false;
        _image = File(pickedFile.path);
        _meterDetectionResult = "Processing...";
      });

      _classifyImage(_image!);
    }
  }

  /// Classify Image (Check if Meter is Detected)
  Future<void> _classifyImage(File imageFile) async {
    try {
      _tensorImage = TensorImage.fromFile(imageFile);
      ImageProcessor imageProcessor = ImageProcessorBuilder()
          .add(ResizeOp(224, 224, ResizeMethod.nearestneighbour))
          .build();

      _tensorImage = imageProcessor.process(_tensorImage);

      var input = _tensorImage.buffer;
      List<List<int>> output = List.generate(1, (_) => List.filled(2, 0));

      _interpreter.run(input, output);

      int predictedIndex = output[0][0] > output[0][1] ? 0 : 1;

      setState(() {
        _meterDetectionResult = predictedIndex == 0 ? "METER DETECTED\nProcessing Bill" : "UNRECOGNIZED OBJECT\nEnsure the meter is visible and TRY AGAIN.";
      });

      if (predictedIndex == 0) {
        // If meter is detected, navigate to unit reading capture screen
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushNamed(context, '/captureReading');
        });
      }
    } catch (e) {
      print("Error classifying image: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when leaving the screen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
            },
            icon: const Icon(
              Icons.home_outlined,
              color: Color(0xFFFD7250),
            ),
          ),
        ],
        title: const Text("Meter Detection"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _image != null ? Image.file(_image!, height: 250) : const SizedBox(),
                const SizedBox(height: 20),
                Text(_meterDetectionResult,textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                if(!timeEnd)
                Text(
                  "Time left: $_secondsLeft sec",
                  style: const TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
                )
                else
                const Text(
                  "Time Limit Exceeded\nTry again...",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if(showButton && !timeEnd)
                Buttons(label: "Capture Meter Image", fn: captureImage),
              ],
            ),
          ),
        ),
      )
    );
  }
}
