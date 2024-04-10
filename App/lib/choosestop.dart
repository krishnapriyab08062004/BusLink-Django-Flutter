import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Choosestop extends StatefulWidget {
  const Choosestop({super.key});

  @override
  State<Choosestop> createState() => _Choosestopstate();
}

class _Choosestopstate extends State<Choosestop> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drop-down Boxes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
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
          backgroundColor: Colors.purple, // Changed app bar color to violet
        ),
        body: DropDownPage(),
      ),
    );
  }
}

class DropDownPage extends StatefulWidget {
  @override
  _DropDownPageState createState() => _DropDownPageState();
}

class _DropDownPageState extends State<DropDownPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> district = [];
  List<Map<String, dynamic>> place = [];
  String? selectedDistrict;
  String? selectedPlace;

  Future<void> fetchDistrict() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await db.collection('tbl_route').get();

      List<Map<String, dynamic>> dist = querySnapshot.docs.map((doc) => {
            'id': doc.id,
            'route': '${doc['startroute_name']} - ${doc['endroute_name']}'.toString(),
          }).toList();
      setState(() {
        district = dist;
      });
    } catch (e) {
      print('Error fetching district data: $e');
    }
  }

  Future<void> fetchPlace(String id) async {
    try {
      selectedPlace = null;
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await db
          .collection('tbl_stop')
          .where('route_id', isEqualTo: id)
          .get();
      List<Map<String, dynamic>> plc = querySnapshot.docs.map((doc) => {
            'id': doc.id,
            'stop': doc['stop_name'].toString(),
          }).toList();
      setState(() {
        place = plc;
      });
    } catch (e) {
      print('Error fetching place data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDistrict();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 300,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Route',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButtonFormField<String>(
              value: selectedDistrict,
              decoration: InputDecoration(
                labelText: 'Route',
                hintText: 'Select Route',
                hintStyle: TextStyle(color: Colors.black26),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDistrict = newValue;
                  fetchPlace(newValue!);
                });
              },
              items: district.map<DropdownMenuItem<String>>(
                (Map<String, dynamic> dist) {
                  return DropdownMenuItem<String>(
                    value: dist['id'],
                    child: Text(dist['route']),
                  );
                },
              ).toList(),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedPlace,
              decoration: InputDecoration(
                labelText: 'Stop',
                hintText: 'Select Stop',
                hintStyle: TextStyle(color: Colors.black26),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black12),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  selectedPlace = newValue;
                });
              },
              items: place.map<DropdownMenuItem<String>>(
                (Map<String, dynamic> place) {
                  return DropdownMenuItem<String>(
                    value: place['id'],
                    child: Text(place['stop']),
                  );
                },
              ).toList(),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Handle submit button press
                  },
                  child: Text('Submit'),
                ),
                SizedBox(width: 25),
                ElevatedButton(
                  onPressed: () {
                    // Handle cancel button press
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
