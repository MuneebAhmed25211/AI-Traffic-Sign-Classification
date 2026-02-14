import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../service/traffic_sign_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TrafficSignService _service = TrafficSignService();

  File? _image;
  String _prediction = "";
  double _confidence = 0.0;

  bool _modelLoaded = false;
  bool _isPredicting = false;

  final List<String> signNames = [
    "Speed limit (20km/h)",                     // 0
    "Speed limit (30km/h)",                     // 1
    "No passing for vehicles over 3.5 metric tons", // 10 ← index 2
    "Right-of-way at the next intersection",    // 11 ← index 3
    "Priority road",                            // 12
    "Yield",                                    // 13
    "Stop",                                     // 14
    "No vehicles",                              // 15
    "Vehicles over 3.5 metric tons prohibited", // 16
    "No entry",                                 // 17
    "General caution",                          // 18
    "Dangerous curve to the left",              // 19
    "Speed limit (50km/h)",                     // 2   ← index 12 !!
    "Dangerous curve to the right",             // 20
    "Double curve",                             // 21
    "Bumpy road",                               // 22
    "Slippery road",                            // 23
    "Road narrows on the right",                // 24
    "Road work",                                // 25
    "Traffic signals",                          // 26
    "Pedestrians",                              // 27
    "Children crossing",                        // 28
    "Bicycles crossing",                        // 29
    "Speed limit (60km/h)",                     // 3   ← index 23 !!
    "Beware of ice/snow",                       // 30
    "Wild animals crossing",                    // 31
    "End of all speed and passing limits",      // 32
    "Turn right ahead",                         // 33
    "Turn left ahead",                          // 34
    "Ahead only",                               // 35
    "Go straight or right",                     // 36
    "Go straight or left",                      // 37
    "Keep right",                               // 38
    "Keep left",                                // 39
    "Speed limit (70km/h)",                     // 4   ← index 34 !!
    "Roundabout mandatory",                     // 40
    "End of no passing",                        // 41
    "End of no passing by vehicles over 3.5 metric tons", // 42
    "Speed limit (80km/h)",                     // 5
    "End of speed limit (80km/h)",              // 6
    "Speed limit (100km/h)",                    // 7
    "Speed limit (120km/h)",                    // 8
    "No passing"                                // 9
  ];


  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    await _service.loadModel();
    setState(() {
      _modelLoaded = true;
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked == null) return;

    setState(() {
      _isPredicting = true;
    });

    final imageFile = File(picked.path);
    final bytes = await imageFile.readAsBytes();

    final output = await _service.predict(bytes);

    double maxScore = output.reduce((a, b) => a > b ? a : b);
    int index = output.indexOf(maxScore);

    setState(() {
      _isPredicting = false;
      _image = imageFile;
      _prediction = signNames[index];
      _confidence = maxScore * 100;
    });
  }

  @override
  void dispose() {
    _service.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Traffic Sign Classifier"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image != null
                  ? Image.file(_image!, height: 200)
                  : const Text(
                "No Image Selected",
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _modelLoaded ? pickImage : null,
                child: const Text("Capture Traffic Sign"),
              ),

              const SizedBox(height: 20),

              if (_isPredicting)
                const CircularProgressIndicator(),

              if (_prediction.isNotEmpty && !_isPredicting)
                Column(
                  children: [
                    Text(
                      "Prediction: $_prediction",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Confidence: ${_confidence.toStringAsFixed(2)}%",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
