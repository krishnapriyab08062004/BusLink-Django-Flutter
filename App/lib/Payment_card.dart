import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Paymentcard extends StatefulWidget {
  const Paymentcard({super.key});

  @override
  State<Paymentcard> createState() => _PayScreenState();
}

class _PayScreenState extends State<Paymentcard> {
  late List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  void fetchPayments() async {
    List<Map<String, dynamic>> contextList = [];
    int currentMonth = DateTime.now().month;
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    FirebaseFirestore db = FirebaseFirestore.instance;
    String sid = '';

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('tbl_userregistration')
        .where('User_id', isEqualTo: userId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      sid = querySnapshot.docs.first
          .id; // Assuming 'id' is the field that contains the user's ID
    }

    for (String month in months) {
      QuerySnapshot paymentsRef = await db
          .collection("tbl_payment")
          .where("stu_id", isEqualTo: sid)
          .where("pay_month", isEqualTo: month)
          .get();

      int status; // Changed the type to int here
      if (paymentsRef.docs.isNotEmpty) {
        status = 1; // Using integers directly
      } else {
        status = 0;
      }

      if (months.indexOf(month) + 1 > currentMonth) {
        status = 2;
      }

      contextList.add(
          {"month": month, "status": status, "current_month": currentMonth});
    }

    setState(() {
      data = contextList;
    });
    print(contextList);
  }

  String getStatusText(int status) {
    switch (status) {
      case 1:
        return 'Paid';
      case 2:
        return 'Upcoming';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    int currentYear = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 60, 60, 231),
        title: Text(
          'Payment Card',
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                Text(
                  'Payment Card - $currentYear',
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
                DataTable(
                  columns: [
                    DataColumn(
                      label: Text(
                        'SL.No',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Month',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: List<DataRow>.generate(
                    data.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text(data[index]['month'])),
                        DataCell(
                          data[index]['status'] == 0
                              ? ElevatedButton(
                                  onPressed: () {
                                    // Add logic to handle the pay button press
                                    // handlePayButton(data[index]['month']);
                                  },
                                  child: Text('Pay'),
                                )
                              : Text(
                                  getStatusText(data[index][
                                      'status']), // Empty cell if status is not 0
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
