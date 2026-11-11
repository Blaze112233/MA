import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Support')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          ListTile(
            leading: Icon(Icons.phone_rounded, color: Colors.green),
            title: Text('Customer Care Hotline'),
            subtitle: Text('+855 23 999 888'),
          ),
          ListTile(
            leading: Icon(Icons.email_outlined, color: Colors.blue),
            title: Text('Support Email'),
            subtitle: Text('support@techhub.store.com.kh'),
          ),
          ListTile(
            leading: Icon(Icons.location_on_outlined, color: Colors.redAccent),
            title: Text('Headquarters'),
            subtitle: Text('Preak Somroang, Takhmao, Kandal, Cambodia'),
          ),
        ],
      ),
    );
  }
}