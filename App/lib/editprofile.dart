import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => EditprofileState();
}

class EditprofileState extends State<Editprofile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      if (userId != null) {
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await FirebaseFirestore.instance
                .collection('tbl_userregistration')
                .where('User_id', isEqualTo: userId)
                .limit(1)
                .get();
        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          setState(() {
            _nameController.text = doc['user_name'] ?? '';
            _contactController.text = doc['user_contact'] ?? '';
            _addressController.text = doc['user_address'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          showErrorDialog('User data not found');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        showErrorDialog('User ID is null');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showErrorDialog('Error loading data: $e');
    }
  }

  void editProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;

      if (userId != null) {
        try {
          await FirebaseFirestore.instance
              .collection('tbl_userregistration')
              .where('User_id', isEqualTo: userId)
              .get()
              .then((querySnapshot) {
            if (querySnapshot.docs.isNotEmpty) {
              final docId = querySnapshot.docs.first.id;
              FirebaseFirestore.instance
                  .collection('tbl_userregistration')
                  .doc(docId)
                  .update({
                'user_name': _nameController.text,
                'user_contact': _contactController.text,
                'user_address': _addressController.text,
              });
              showSuccessDialog('Profile updated successfully');
            }
          });
        } catch (e) {
          showErrorDialog('Error updating document: $e');
        }
      } else {
        showErrorDialog('User ID is null');
      }
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text('User editprofile'),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Name',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Contact',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your contact';
                          }
                          // Add additional contact validation if needed
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          hintText: 'Enter Address',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      ElevatedButton(
                        onPressed: editProfile,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
          ),
    );
  }
}