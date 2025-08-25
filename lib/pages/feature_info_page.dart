import 'package:flutter/material.dart';

// FeatureInfoPage
// Informational page explaining how the app works.
class FeatureInfoPage extends StatelessWidget {
  const FeatureInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text('How Everything Works')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Center(
            //TODO: make this page
            child: Text(
              'Coming soon!',
              style: TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
