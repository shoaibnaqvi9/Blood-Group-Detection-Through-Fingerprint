import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:blood_group_detect/screens/home.dart';
import 'package:blood_group_detect/screens/about.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _suggestionController = TextEditingController();

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
            const Text("Contact"),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Contact Us",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "We would love to hear from you! If you have any questions, feedback, or suggestions"
                "regarding the Blood Group Detection project, please reach out to us through this form:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Suggestion Field
                    TextFormField(
                      controller: _suggestionController,
                      decoration: const InputDecoration(
                        labelText: "Suggestion",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.edit),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please provide a suggestion";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final String name = _nameController.text;
                          final String suggestion = _suggestionController.text;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Thank you, $name! Your message has been received."),
                            ),
                          );
                          _nameController.clear();
                          _suggestionController.clear();
                        }
                      },
                      child: const Text("Submit"),
                    ),
                  ],
                ),
              ),
              const Divider(height: 40),
              const Text(
                "Follow us on social media:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
                    onPressed: () {
                      // Open Facebook link
                    },
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.twitter, color: Colors.lightBlue),
                    onPressed: () {
                      // Open Twitter link
                    },
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.instagram, color: Colors.pink),
                    onPressed: () {
                      // Open Instagram link
                    },
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}