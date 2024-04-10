import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'package:fluttertoast/fluttertoast.dart';

class QRResult extends StatefulWidget {
  final Map<String, dynamic> qrData;
  const QRResult({super.key, required this.qrData});

  @override
  State<QRResult> createState() => _QRResultState();
}

class _QRResultState extends State<QRResult> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  DateTime now = DateTime.now();
  bool attendanceRegistered = false;

  @override
  void initState() {
    super.initState();
    checkAttendance();
  }

  Future<void> checkAttendance() async {
    try {
      String formattedDate = "${now.year}-${now.month}-${now.day}";
      QuerySnapshot querySnapshot = await db
          .collection('attendance')
          .where('userId', isEqualTo: widget.qrData['id'])
          .where('date', isEqualTo: formattedDate)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          attendanceRegistered = true;
        });
      } else {
        setState(() {
          attendanceRegistered = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> register() async {
    try {
      String formattedDate = "${now.year}-${now.month}-${now.day}";
      final data = <String, dynamic>{
        'stu_id': widget.qrData['id'],
        'date': formattedDate
      };
      await db
          .collection('attendance')
          .add(data)
          .then((DocumentReference doc) => Fluttertoast.showToast(
                msg: 'Attendence Registered',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
              ));
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
        msg: 'Failed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Data'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ID: ${widget.qrData['id']}'),
            attendanceRegistered
                ? const Text(
                    'Today\'s attendance already registered',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                : ElevatedButton(
                    onPressed: () {
                      register();
                    },
                    child: const Text('Register Attendance'),
                  ),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}