import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class pagePage extends StatefulWidget {
  const pagePage({super.key});
  @override
  _pagePageState createState() => _pagePageState();
}

class _pagePageState extends State<pagePage> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _capturedImage;
  XFile? _browsedImage;

  // Path to save the captured image
  final String savePath = r"C:\FYPproject\dataset\New folder";

  Future<void> _askCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      // Request camera permission
      status = await Permission.camera.request();
      if (status.isGranted) {
        _openCamera();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Camera permission is required.")),
        );
      }
    } else if (status.isGranted) {
      _openCamera();
    }
  }

  Future<void> _openCamera() async {
    try {
      final XFile? image =
          await _imagePicker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final File imageFile = File(image.path);

        // Save image to the local system path
        final String newPath = "$savePath/${DateTime.now().millisecondsSinceEpoch}.jpg";
        await imageFile.copy(newPath);

        setState(() {
          _capturedImage = XFile(newPath);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image captured and saved successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to open camera: $e")),
      );
    }
  }

  Future<void> _browseImage() async {
    try {
        final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);

        if (image != null) {
            setState(() {
                _browsedImage = image;
            });

            final url = Uri.parse('http://your_django_server/api/predict/');
            final request = http.MultipartRequest('POST', url)
              ..files.add(await http.MultipartFile.fromPath('file', image.path));

            final response = await request.send();

            if (response.statusCode == 200) {
                final responseBody = await response.stream.bytesToString();
                print("Prediction Result: $responseBody");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Prediction successful!")),
                );
            } else {
                print("Error: ${response.reasonPhrase}");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Prediction failed!")),
                );
            }
        }
    }
    catch (e) {
        print("Failed to browse image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to browse image: $e")),
        );
    }
  }
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Welcome, ${_user?.email ?? "Guest"}",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "page Options",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Divider(),
            Center(
              child: Column(
                children: [
                  // Display captured image
                  if (_capturedImage != null) ...[
                    const Text("Captured Image:"),
                    const SizedBox(height: 10),
                    Image.file(
                      File(_capturedImage!.path),
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _askCameraPermission,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Capture with Camera"),
                  ),
                  const SizedBox(height: 20),
                  // Display browsed image
                  if (_browsedImage != null) ...[
                    const Text("Browsed Image:"),
                    const SizedBox(height: 10),
                    Image.file(
                      File(_browsedImage!.path),
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _browseImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Browse from Gallery"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}