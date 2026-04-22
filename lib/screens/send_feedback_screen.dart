import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SendFeedbackScreen extends StatefulWidget {
  const SendFeedbackScreen({super.key});

  @override
  State<SendFeedbackScreen> createState() => _SendFeedbackScreenState();
}

class _SendFeedbackScreenState extends State<SendFeedbackScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _sendFeedback() async {
    final Uri email = Uri(
      scheme: 'mailto',
      path: 'smartstudyplanner05@gmail.com',
      query: 'subject=App Feedback&body=${_controller.text}',
    );

    await launchUrl(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Feedback"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Tell us what you think about the app",
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Write your feedback...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _sendFeedback,
              child: const Text("Send"),
            )
          ],
        ),
      ),
    );
  }
}