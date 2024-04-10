import 'package:flutter/material.dart';

class Paymentcard extends StatefulWidget {
  const Paymentcard({Key? key}) : super(key: key);

  @override
  State<Paymentcard> createState() => _PayScreenState();
}

class _PayScreenState extends State<Paymentcard> {
  late int currentYear;
  late List<String> months;

  @override
  void initState() {
    super.initState();
    // Initialize current year and list of months
    currentYear = DateTime.now().year;
    months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
  }

  @override
  Widget build(BuildContext context) {
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
        child: ListView(
          children: <Widget>[
            Center(
              child: Text(
                'Payment Card - $currentYear',
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            DataTable(
              columns: [
                DataColumn(
                  label: const Text(
                    'SL.No',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: const Text(
                    'Month',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: const Text(
                    'Action',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: List<DataRow>.generate(
                months.length,
                (index) => DataRow(cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Text(months[index])),
                  DataCell(const Text('')),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
