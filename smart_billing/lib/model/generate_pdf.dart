import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';

class PDFManager {
  final List<String> fieldOrder = [
    'consumer no', 'consumer name', 
    'bill#', 'bill date', 'due date', 'disconn dt', 'load', 'consumer phase',
    'prv rd dt', 'prs rd date', 'unit', 'curr', 'prev', 'cons',
    'Fixed Charge', 'Meter Rent', 'Energy Charge', 'duty', 'FC Subsidy', 'EC Subsidy','Monthly Fuel Surcharge', 'total'
  ];

  final Map<String, String> fieldLabels = {
    'consumer no': 'Consumer Number', 'consumer name': 'Name',
    'bill#': 'Bill Number', 'bill date': 'Bill Date', 'due date': 'Due Date', 'disconn dt': 'Disconnection Date',
    'load': 'Load', 'consumer phase': 'Phase', 'prv rd dt': 'Previous Reading Date',
    'prs rd date': 'Present Reading Date', 'unit': 'Unit', 'curr': 'Current Reading',
    'prev': 'Previous Reading', 'cons': 'Consumed Units',
    'Fixed Charge': 'Fixed Charge', 'Meter Rent': 'Meter Rent',
    'Energy Charge': 'Energy Charge', 'duty': 'Duty', 'FC Subsidy': 'FC Subsidy', 
    'EC Subsidy': 'EC Subsidy', 'Monthly Fuel Surcharge': 'Monthly Fuel Surcharge', 'total': 'Total Amount Payable'
  };
  Future<void> generateAndDownloadPDF(Map<String, dynamic> billData) async {
    try {
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();
      final PdfGraphics graphics = page.graphics;
      const double startX = 20, startY = 40, lineSpacing = 25;
      double currentY = startY;

      // Add Title
      graphics.drawString(
        "KSEB ELECTRICITY BILL",
        PdfStandardFont(PdfFontFamily.courier, 24, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(startX, currentY, 500, 40),
      );
      currentY += 50;

      // Add Bill Details
      final PdfFont font = PdfStandardFont(PdfFontFamily.courier, 14);
      // billData.forEach((key, value) {
      //   graphics.drawString("$key :  $value", font, bounds: Rect.fromLTWH(startX, currentY, 500, 20));
      //   currentY += lineSpacing;
      // });
             
      for (var field in fieldOrder) {
        graphics.drawString('${fieldLabels[field]?.padRight(23)}: ${billData[field]}', font, bounds: Rect.fromLTWH(startX, currentY, 500, 20));
        currentY += lineSpacing;
      }
      // Save the PDF
      final List<int> bytes = await document.save();
      document.dispose();

      // Save the PDF file to device storage
      final Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception('Failed to get external storage directory');
      }
      final String path = directory.path;
      final File file = File('$path/bill_on_${billData['bill date']}.pdf');
      await file.writeAsBytes(bytes, flush: true);

      // Open the saved PDF file using open_file plugin
      OpenFile.open(file.path);
    } catch (e) {
      print('Error generating or saving PDF: $e');
    }
  }
}
