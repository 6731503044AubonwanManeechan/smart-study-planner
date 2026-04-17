import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_language.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

@override
Widget build(BuildContext context) {
  final lang = Provider.of<AppLanguage>(context);

  return Scaffold(
    appBar: AppBar(
      title: Text(lang.getText("Select Language", "เลือกภาษา")),
    ),
    body: Column(
      children: [

        ListTile(
          title: Text(lang.getText("English", "อังกฤษ")),
          onTap: () {
            lang.changeLanguage('en');
            Navigator.pop(context);
          },
        ),

        ListTile(
          title: Text(lang.getText("Thai", "ไทย")),
          onTap: () {
            lang.changeLanguage('th');
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}