import 'package:flutter/material.dart';

final TextStyle title = TextStyle(
  color: Colors.grey[600],
  fontWeight: FontWeight.bold,
  fontSize: 20,
);
TextStyle body = TextStyle(
  color: Colors.grey[400],
  fontWeight: FontWeight.bold,
  fontSize: 16,
);

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text('About')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // About App
          Text('Secure Password Generator', style: title),
          Text(
            'A simple, local password generator for creating strong, secure passwords.',
            style: body,
          ),
          SizedBox(height: 15),

          // Disclaimer
          Text('Disclaimer', style: title),
          Text(
            '⚠️This app is provided as-is. It generates strong passwords locally, but use at your own risk. For critical accounts, consider a professional password manager.',
            style: body,
          ),
          SizedBox(height: 15),

          // Privacy
          Text('Privacy', style: title),
          Text(
            'This app does not collect or share any personal data.',
            style: body,
          ),
          SizedBox(height: 15),

          // Author
          Text('Author', style: title),
          Text('euhfs', style: body),
          SizedBox(height: 15),

          // Contact
          Text('Contact', style: title),
          Text('euhfs2@gmail.com', style: body),
          SizedBox(height: 15),

          // App Version
          Text('Version', style: title),
          Text('1.0.0', style: body),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}
