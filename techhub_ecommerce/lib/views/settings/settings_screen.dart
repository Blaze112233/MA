import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive flash deals and order updates'),
            value: _notifications,
            onChanged: (val) => setState(() => _notifications = val),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: const Text('Language'),
            trailing: const Text('English (US)', style: TextStyle(color: Colors.grey)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.attach_money_rounded),
            title: const Text('Currency'),
            trailing: const Text('USD (\$) / KHR (៛)', style: TextStyle(color: Colors.grey)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}