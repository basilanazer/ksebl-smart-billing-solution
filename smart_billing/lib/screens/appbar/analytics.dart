import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  List<FlSpot> unitSpots = [];
  List<FlSpot> priceSpots = [];
  Map<double, String> xLabels = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('1112345671234')
          .orderBy(FieldPath.documentId)
          .get();

      final docs = querySnapshot.docs;
      List<Map<String, dynamic>> parsedData = docs.map((doc) {
        final idParts = doc.id.split('-');
        final year = int.parse(idParts[0]);
        final month = int.parse(idParts[1]);
        final units = double.parse(doc['u']);
        final price = double.parse(doc['p']); // Fetch 'p' for prices
        return {
          'date': DateTime(year, month + 1),
          'units': units,
          'price': price,
        };
      }).toList();

      parsedData.sort((a, b) => a['date'].compareTo(b['date']));
      final latest6Months = parsedData.take(6).toList();

      List<FlSpot> chartUnitSpots = [];
      List<FlSpot> chartPriceSpots = [];
      Map<double, String> labels = {};

      for (int i = 0; i < latest6Months.length; i++) {
        chartUnitSpots.add(FlSpot(i.toDouble(), latest6Months[i]['units']));
        chartPriceSpots.add(FlSpot(i.toDouble(), latest6Months[i]['price']));
        labels[i.toDouble()] =
            "${latest6Months[i]['date'].month}/${latest6Months[i]['date'].year}";
      }

      setState(() {
        unitSpots = chartUnitSpots;
        priceSpots = chartPriceSpots;
        xLabels = labels;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Widget buildChart(BuildContext context, String yAxisTitle,
      List<FlSpot> chartSpots, Map<double, String> labels) {
    String? dxn = yAxisTitle == "Units" ? "left" : "right";
    String? next = yAxisTitle == "Units" ? "Price" : "Units";
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 25, bottom: 30),
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: calculateMaxY(chartSpots),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartSpots,
                      gradient: LinearGradient(
                        colors: [Color(0xFF4D4C7D), Color(0xFFFD7250)],
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        axisNameWidget: Text(
                          'Month/Year',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              labels[value] ?? '',
                              style: const TextStyle(fontSize: 13),
                            );
                          },
                          reservedSize: 30,
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            reservedSize: 50,
                            showTitles: true,
                          ),
                          axisNameWidget: RotatedBox(
                            quarterTurns: 2,
                            child: Text(
                              yAxisTitle,
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ))),
                ),
              ),
            ),
          ),
          Text(yAxisTitle + " vs Month/Year",
              style: TextStyle(
                  color: Color(0xFFFD7250),
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
          SizedBox(
            height: 20,
          ),
          Text("Swipe " + dxn + " to Analyse",
              style: TextStyle(
                  color: Color(0xFF4D4C7D),
                  fontWeight: FontWeight.bold,
                  fontSize: 20)),
          Text(next + " vs Month/Year",
              style: TextStyle(
                  color: Color(0xFF4D4C7D),
                  fontWeight: FontWeight.bold,
                  fontSize: 15))
        ],
      ),
    );
  }

  double calculateMaxY(List<FlSpot> spots) {
    double maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    // int val = maxY.toString().replaceAll('.', '').length;
    double nextval = pow(10, 2) * 5 + maxY;
    return nextval;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/dashboard');
              },
              icon: Icon(Icons.dashboard_outlined, color: Color(0xFFFD7250))),
        ],
        title: const Text('Analytics',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : PageView(
              children: [
                Center(
                  child: buildChart(context, 'Units', unitSpots, xLabels),
                ), // Units vs Months
                Center(
                  child: buildChart(context, 'Price', priceSpots, xLabels),
                ), // Price vs Months
              ],
            ),
    );
  }
}
