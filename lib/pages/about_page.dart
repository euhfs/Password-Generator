import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

// Function to open the website in default browser
void _launchUrl() async {
  final url = Uri.parse('https://euhfs.onrender.com');
  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text('About')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            // Image
            Image.asset('assets/imgs/aboutpage-img.jpg'),
            Text(
              'Image by TheDigitalArtist from Pixabay',
              style: TextStyle(
                color: const Color.fromARGB(100, 189, 189, 189),
                fontSize: 9,
              ),
              textAlign: TextAlign.end,
            ),
            const SizedBox(height: 6),
        
            // About App
            Text('Secure Password Generator', style: title),
            Text(
              'A simple, local password generator for creating strong, secure passwords.',
              style: body,
            ),
            const SizedBox(height: 15),
        
            // Disclaimer
            Text('Disclaimer', style: title),
            Text(
              '⚠️This app is provided as-is. It generates strong passwords locally, but use at your own risk. For critical accounts, consider a professional password manager.',
              style: body,
            ),
            const SizedBox(height: 10),
        
            // Privacy
            Text('Privacy', style: title),
            Text(
              'This app does not collect or share any personal data.',
              style: body,
            ),
            const SizedBox(height: 10),
        
            // Author
            Text('Author', style: title),
            Text('euhfs', style: body),
            const SizedBox(height: 10),
        
            // Contact
            Text('Contact', style: title),
            Text('euhfs2@gmail.com', style: body),
            const SizedBox(height: 10),
        
            // Website
            Text('Website', style: title),
            TextButton(
              onPressed: _launchUrl,
              style: ButtonStyle(alignment: Alignment(-1.15, 0)),
              child: Text('https://euhfs.onrender.com', style: body),
            ),
            const SizedBox(height: 0),
        
            // App Version
            Text('Version + Build Number', style: title),
            Text('1.0.0+1', style: body),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
