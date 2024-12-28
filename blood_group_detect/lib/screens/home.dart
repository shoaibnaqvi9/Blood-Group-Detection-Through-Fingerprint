import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blood_group_detect/screens/contact.dart';
import 'package:blood_group_detect/screens/about.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _capturedImage;
  XFile? _browsedImage;

  // Path to save the captured image
  // final String savePath = r"C:\FYPproject\dataset\New folder";
  // Google Drive API constants
  final String _mainFolderId = '1-9DagGfSQwRJVf5S17qbRDrW5iURwiy8';

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
        // final String newPath = "$savePath/${DateTime.now().millisecondsSinceEpoch}.jpg";
        // await imageFile.copy(newPath);

        // setState(() {
        //   _capturedImage = XFile(newPath);
        // });

        final String bmpPath =
            "${imageFile.parent.path}/${DateTime.now().millisecondsSinceEpoch}.bmp";
        await imageFile.copy(bmpPath);

        // Upload to Google Drive
        await _uploadToFlaskServer(File(bmpPath));

        setState(() {
          _capturedImage = XFile(bmpPath);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image captured, and uploaded successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to capture image: $e")),
      );
    }
  }

  Future<void> _uploadToFlaskServer(File file) async {
    try {
      final url = Uri.parse('http://127.0.0.1:5000/upload'); // Flask server URL
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print("File uploaded successfully: $responseBody");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("File uploaded successfully!")),
        );
      } else {
        print("Error: ${response.reasonPhrase}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload file!")),
        );
      }
    } catch (e) {
      print("Failed to upload file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload file: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'lib/assets/logo.png',
              height: 40,
              width: 40,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 5),
            const Text("Fingerprint Detection"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
            child: const Text("Home", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
            child: const Text("About", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactPage()),
              );
            },
            child: const Text("Contact", style: TextStyle(color: Colors.black)),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFFFCDD2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Blood Group Detection",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Display user email if available
              if (_user != null) ...[
                Text(
                  "Hi, ${_user?.email}",
                  style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ],
              const Text(
                "This project aims to detect blood groups using fingerprint analysis. "
                    "It leverages convolutional neural networks (CNNs) to achieve high accuracy "
                    "and efficiency. Users can upload their fingerprint images, and the system "
                    "will analyze and predict their blood group.",
                style: TextStyle(fontSize: 16),
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
      ),
    );
  }


  // Future<void> _browseImage() async {
  //   try {
  //       final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
  //
  //       if (image != null) {
  //           setState(() {
  //               _browsedImage = image;
  //           });
  //
  //           final url = Uri.parse('http://http://127.0.0.1:8000/api/predict/');
  //           final request = http.MultipartRequest('POST', url)
  //             ..files.add(await http.MultipartFile.fromPath('file', image.path));
  //
  //           final response = await request.send();
  //
  //           if (response.statusCode == 200) {
  //               final responseBody = await response.stream.bytesToString();
  //               print("Prediction Result: $responseBody");
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(content: Text("Prediction successful!")),
  //               );
  //           } else {
  //               print("Error: ${response.reasonPhrase}");
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(content: Text("Prediction failed!")),
  //               );
  //           }
  //       }
  //   }
  //   catch (e) {
  //       print("Failed to browse image: $e");
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Failed to browse image: $e")),
  //       );
  //   }
  // }

  Future<void> _browseImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final File imageFile = File(image.path);

        // Save image to the local system path in BMP format
        final String bmpPath =
            "${imageFile.parent.path}/${DateTime.now().millisecondsSinceEpoch}.bmp";
        await imageFile.copy(bmpPath);

        // Upload to Google Drive
        await _uploadToFlaskServer(File(bmpPath));

        setState(() {
          _browsedImage = XFile(bmpPath);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image browsed, and uploaded successfully!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to browse image: $e")),
      );
    }
  }


  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Image.asset(
//               'lib/assets/logo.png',
//               height: 40,
//               width: 40,
//               fit: BoxFit.cover,
//             ),
//             const SizedBox(width: 5),
//             const Text("Home"),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const HomePage()),
//               );
//             },
//             child: const Text("Home", style: TextStyle(color: Colors.black)),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const AboutPage()),
//               );
//             },
//             child: const Text("About", style: TextStyle(color: Colors.black)),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const ContactPage()),
//               );
//             },
//             child: const Text("Contact", style: TextStyle(color: Colors.black)),
//           ),
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: _signOut,
//           ),
//         ],
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.white, Color(0xFFFFCDD2)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Blood Group Detection",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 "Hi, ${_user?.email}",
//                 style:
//                     const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
//               ),
//               const Text(
//                 "This project aims to detect blood groups using fingerprint analysis. "
//                 "It leverages convolutional neural networks (CNNs) to achieve high accuracy "
//                 "and efficiency. Users can upload their fingerprint images, and the system "
//                 "will analyze and predict their blood group.",
//                 style: TextStyle(fontSize: 16),
//               ),
//               const Divider(),
//               Center(
//               child: Column(
//                 children: [
//                   // Display captured image
//                   if (_capturedImage != null) ...[
//                     const Text("Captured Image:"),
//                     const SizedBox(height: 10),
//                     Image.file(
//                       File(_capturedImage!.path),
//                       height: 200,
//                       width: 200,
//                       fit: BoxFit.cover,
//                     ),
//                   ],
//                   const SizedBox(height: 20),
//                   ElevatedButton.icon(
//                     onPressed: _askCameraPermission,
//                     icon: const Icon(Icons.camera_alt),
//                     label: const Text("Capture with Camera"),
//                   ),
//                   const SizedBox(height: 20),
//                   // Display browsed image
//                   if (_browsedImage != null) ...[
//                     const Text("Browsed Image:"),
//                     const SizedBox(height: 10),
//                     Image.file(
//                       File(_browsedImage!.path),
//                       height: 200,
//                       width: 200,
//                       fit: BoxFit.cover,
//                     ),
//                   ],
//                   const SizedBox(height: 20),
//                   ElevatedButton.icon(
//                     onPressed: _browseImage,
//                     icon: const Icon(Icons.photo_library),
//                     label: const Text("Browse from Gallery"),
//                   ),
//                 ],
//               ),
//             ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
