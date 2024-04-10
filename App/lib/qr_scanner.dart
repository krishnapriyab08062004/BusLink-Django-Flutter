import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'qr_result.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  late QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      // Handle scanned QR data here
      print(scanData.code);
      String? data = scanData.code;
      Map<String, dynamic> jsonData = jsonDecode(data!);
      if (jsonData.containsKey('app') && jsonData['app'] == 'BUSLINK') {
        // Proceed only if the scanned QR code is generated from your website
        controller.dispose();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QRResult(qrData: jsonData),
          ),
        );
      } else {
        // Show a Snackbar for invalid QR code
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid QR Code.'),
            duration: Duration(seconds: 5), // Adjust as needed
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}