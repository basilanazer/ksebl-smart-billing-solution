import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'package:smart_billing/screens/ocr/meter_detection.dart';
// Import the meter detection screen

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => BarcodeScannerScreenState();
}

class BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool barcodeFoundFlag = false;
  bool barcodeMatchFlag = false;
  bool isLoading = true;
  String scannedValue = '';
  String message = "Scanning Meter...";
  int countdown = 3; // Countdown before redirection

  @override
  void initState() {
    super.initState();
    scanBarcode();
  }

  /// Barcode Scanner Function
  Future<void> scanBarcode() async {
    try {
      scannedValue = await FlutterBarcodeScanner.scanBarcode(
        "#FD7250", "Cancel", true, ScanMode.BARCODE,
      );

      if (scannedValue != "-1") {
        setState(() {
          barcodeFoundFlag = true;
          message = "Meter Number Scanned: $scannedValue";
        });
        validateMeterNumber();
      } else {
        // If user cancels, navigate to dashboard
        Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
      }
    } catch (e) {
      setState(() {
        message = "Error scanning barcode: $e";
      });
    }
  }

  /// Validate Scanned Meter Number
  Future<void> validateMeterNumber() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      if (email == null || email.isEmpty) throw Exception("Email not found.");

      final consumerNumberDoc = await FirebaseFirestore.instance
          .collection('consumer number')
          .doc(email)
          .get();

      if (!consumerNumberDoc.exists) throw Exception("Consumer number not found.");

      final consumerNumber = consumerNumberDoc.data()?['cons no'];
      if (consumerNumber == null || consumerNumber.isEmpty) throw Exception("Consumer number invalid.");

      final consumerMeterDoc = await FirebaseFirestore.instance
          .collection('consumer')
          .doc(consumerNumber)
          .get();

      if (!consumerMeterDoc.exists) throw Exception("Meter number not found.");

      final meterNumber = consumerMeterDoc.data()?['meter_no'];

      if (meterNumber == scannedValue) {
        setState(() {
          barcodeMatchFlag = true;
          message = "Meter Number Detected : $scannedValue \n\n✅ Meter Number Verified!\n\nRedirecting in $countdown seconds...\n\nCapture the unit recording before timelimit exceeds";
        });

        // Start countdown before redirecting to meter detection
        startCountdown();
      } else {
        setState(() {
          message = "❌ Meter Number Mismatch! Scan again.";
        });
      }
    } catch (e) {
      setState(() {
        message = "Error fetching data: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  /// Countdown before redirecting to meter detection
  void startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 1) {
        setState(() {
          countdown--;
          message = "Meter Number Detected : $scannedValue \n\n✅ Meter Number Verified!\n\nRedirecting in $countdown seconds...\n\nCapture the unit recording before timelimit exceeds";
        });
      } else {
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MeterDetectionScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          //logout
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
            },
            icon: const Icon(
              Icons.home_outlined,
              color: Color(0xFFFD7250),
            ),
          ),
        ],
        title: const Text("Meter Verification")
      ),
      body: SafeArea(
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    barcodeMatchFlag ? CircularProgressIndicator(value: countdown / 3) : const SizedBox(),
                  ],
                ),
        ),
      ),
    );
  }
}
