import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Center(
              child: Text(
                "Help & Support",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 25),

            /// Search
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// FAQ
            const Text("FAQs",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            const SizedBox(height: 15),

            _faqCard(context, "How to create Rest Mode ?"),
            _faqCard(context, "Why are my tasks rescheduled ?"),
            _faqCard(context, "How to add new study plan?"),

            const SizedBox(height: 30),

            /// Contact
            const Text("Contact Us",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            const SizedBox(height: 15),

            _contactCard(context, Icons.chat_bubble_outline,
                "Chat with Support", "Coming soon"),

            _contactCard(context, Icons.email_outlined,
                "Email Us", "Contact via Gmail"),

            _contactCard(context, Icons.bug_report_outlined,
                "Report a Bug", "Send bug report"),

            _contactCard(context, Icons.privacy_tip_outlined,
                "Privacy Policy", ""),
          ],
        ),
      ),
    );
  }

  /// FAQ CLICK
  static Widget _faqCard(BuildContext context, String text) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(text),
            content: const Text("Details will be shown here."),
          ),
        );
      },
      child: _cardUI(
        child: ListTile(
          title: Text(text),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  /// CONTACT CLICK
  static Widget _contactCard(
      BuildContext context, IconData icon, String title, String subtitle) {
    return GestureDetector(
      onTap: () async {

        /// 📩 EMAIL
        if (title == "Email Us") {
          final Uri email = Uri(
            scheme: 'mailto',
            path: 'smartstudyplanner05@gmail.com',
            query: 'subject=Support Request',
          );
          await launchUrl(email);
        }

        /// 🐞 BUG FORM (โปรขึ้น)
        else if (title == "Report a Bug") {
          _showBugForm(context);
        }

        /// 💬 CHAT
        else if (title == "Chat with Support") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Coming soon")),
          );
        }

        /// 🔒 PRIVACY
        else if (title == "Privacy Policy") {
          final Uri url = Uri.parse("https://your-link.com");
          await launchUrl(url);
        }
      },
      child: _cardUI(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  /// BUG FORM DIALOG (🔥 ตัวนี้ทำให้ดูโปร)
  static void _showBugForm(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Report a Bug"),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "Describe your issue...",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final Uri email = Uri(
                scheme: 'mailto',
                path: 'smartstudyplanner05@gmail.com',
                query: 'subject=Bug Report&body=${controller.text}',
              );
              await launchUrl(email);
              Navigator.pop(context);
            },
            child: const Text("Send"),
          )
        ],
      ),
    );
  }

  /// UI CARD
  static Widget _cardUI({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: child,
    );
  }
}