import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blood_group_detect/screens/home.dart';
import 'package:blood_group_detect/screens/contact.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
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
            const SizedBox(width: 10),
            const Text("About"),
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
            onPressed: () => _signOut(context),
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
        child: const SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "About Blood Group Detection",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Blood Group Detection is a groundbreaking project focused on leveraging "
                    "advanced machine learning techniques, particularly convolutional neural "
                    "networks (CNNs), to analyze fingerprint patterns and predict blood groups. "
                    "This innovative approach aims to provide a quick, non-invasive method for "
                    "determining blood groups, which can be particularly beneficial in medical emergencies.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "Our mission is to make blood group detection accessible, reliable, and efficient for "
                "everyone, using state-of-the-art technology to bridge the gap between medical science "
                "and artificial intelligence.",
                style: TextStyle(fontSize: 16),
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}