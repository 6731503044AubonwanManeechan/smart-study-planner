import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_language.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Language"),
      ),
      body: Column(
        children: [

          ListTile(
            title: const Text("English"),
            onTap: () {
              Provider.of<AppLanguage>(context, listen: false)
                  .changeLanguage('en');
              Navigator.pop(context);
            },
          ),

          ListTile(
            title: const Text("ไทย"),
            onTap: () {
              Provider.of<AppLanguage>(context, listen: false)
                  .changeLanguage('th');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
