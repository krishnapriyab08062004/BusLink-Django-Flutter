import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Choosestop extends StatefulWidget {
  const Choosestop({Key? key}) : super(key: key);

  @override
  State<Choosestop> createState() => _Choosestopstate();
}

class _Choosestopstate extends State<Choosestop> {
  String? sid;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserId();
  }

  Future<void> fetchUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      try {
        QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
            .instance
            .collection('tbl_student')
            .where('stu_id', isEqualTo: userId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            sid = querySnapshot.docs.first.id;
          });
          fetchStopData(); // Fetch stop data once user ID is obtained
        } else {
          setState(() {
            isLoading = false; // Set loading to false if user ID document is not found
          });
        }
      } catch (e) {
        print('Error fetching user ID: $e');
        setState(() {
          isLoading = false; // Set loading to false in case of an error
        });
      }
    } else {
      print('User is not authenticated.');
      setState(() {
        isLoading = false; // Set loading to false if user is not authenticated
      });
    }
  }

  Future<void> fetchStopData() async {
  try {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore
        .instance
        .collection('tbl_stdstp')
        .where('stu_id', isEqualTo: sid) // Add where condition here
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      } else {
        throw Exception('Document not found');
      }
    });

    if (documentSnapshot.exists) {
      // Here you can set your data into a list or perform any other actions
      print('Stop data: ${documentSnapshot.data()}');
    } else {
      print('Document does not exist.');
    }
  } catch (e) {
    print('Error fetching stop data: $e');
  } finally {
    setState(() {
      isLoading = false; // Set loading to false once data fetching is complete
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Choose Stop',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : sid != null
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Text('Stop data loaded.'),
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Text('User ID not found.'),
                  ),
                ),
    );
  }
}
