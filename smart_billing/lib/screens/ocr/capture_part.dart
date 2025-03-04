//import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageCapture extends StatefulWidget {
  const ImageCapture({super.key});

  @override
  State<ImageCapture> createState() => _ImageCaptureState();
}

class _ImageCaptureState extends State<ImageCapture> {
  //final ImagePicker _picker = ImagePicker();

  // bool isLoading = true;
  //File? _image;
  bool barcodeFoundFlag = false;
  bool barcodeMatchFlag = false;
  bool isloading = true;
  String scannedValue = '';

  Future<void> captureMeter() async {
    try {
      scannedValue = await FlutterBarcodeScanner.scanBarcode(
        "#FD7250", // Color for the scanning line
        "Cancel", // Cancel button text
        true, // Show flash option
        ScanMode.BARCODE, // Use ScanMode.QR for QR codes
      );
      if (scannedValue != "-1") {
        // "-1" means scan was canceled
        setState(() {
          barcodeFoundFlag = true;
          scannedValue = scannedValue;
        });
      } else {
        setState(() {
          barcodeFoundFlag = false;
        });
      }
      fetchData();
      print("Scanned Barcode: $scannedValue");
    } catch (e) {
      print("Error scanning barcode: $e");
    }
    // finally {
    //   setState(() {
    //     isloading = false;
    //   });
    // }
  }

  Future<void> fetchData() async {
    try {
      //String msg = 'Some error occurred';

      // Fetch stored email from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      if (email == null || email.isEmpty) {
        throw Exception("Email not found in SharedPreferences.");
      }

      // Fetch consumer number from 'consumer number' collection
      final consumerNumberDoc = await FirebaseFirestore.instance
          .collection('consumer number')
          .doc(email)
          .get();

      if (!consumerNumberDoc.exists) {
        throw Exception("Consumer number not found for the given email.");
      }

      final consumerNumber = consumerNumberDoc.data()?['cons no'];
      if (consumerNumber == null || consumerNumber.isEmpty) {
        throw Exception("Consumer number is empty or invalid.");
      }

      // Fetch meter number from 'consumer' collection
      final consumerMeterDoc = await FirebaseFirestore.instance
          .collection('consumer')
          .doc(consumerNumber)
          .get();

      if (!consumerMeterDoc.exists) {
        throw Exception(
            "Meter number not found for the given consumer number.");
      }

      final meterNumber = consumerMeterDoc.data()?['meter_no'];
      print("Database Meter Number: $meterNumber");
      print("Scanned Meter Number: $scannedValue");

      if (meterNumber == scannedValue) {
        setState(() {
          barcodeMatchFlag = true;
        });
        print("Meter numbers match!");
      } else {
        print("Meter numbers do NOT match!");
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    captureMeter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         Navigator.of(context).pushReplacementNamed('/dashboard');
        //       },
        //       icon: const Icon(Icons.dashboard_outlined, color: Color(0xFFFD7250))),
        // ],
        title: const Text('Bill',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SafeArea(
          child: Center(
        child: isloading
            ? const CircularProgressIndicator()
            : Center(
                child: Column(
                  children: [
                    Text(barcodeFoundFlag
                        ? "Scanned Value is $scannedValue"
                        : "No Barcode Found!"),
                    Text(barcodeMatchFlag
                        ? "Barcode value same as that in database"
                        : "Barcode value different from that in database"),
                  ],
                ),
              ),
      )),
    );
  }
}
