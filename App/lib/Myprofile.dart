import 'changepassword.dart';
import 'editprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 60, 231),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/dummy.jpg'),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Your Name',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(
                Icons.mail,
                color: Colors.grey[600],
              ),
              title: Text(
                'user@example.com',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.phone,
                color: Colors.grey[600],
              ),
              title: Text(
                '+1234567890',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.location_on,
                color: Colors.grey[600],
              ),
              title: Text(
                'Your Address',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Editprofile(),
                  ),
                );
              },
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const ChangePassword(),
                //   ),
                // );
              },
              child: const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
