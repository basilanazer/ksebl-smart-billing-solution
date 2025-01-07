import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    String msg = 'Some error occured';
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      if (email == null || email.isEmpty) {
        msg = "Email not found in SharedPreferences.";
        throw Exception();
      }

      // Fetch consumer number from consumer_number collection
      final consumerNumberDoc = await FirebaseFirestore.instance
          .collection('consumer number')
          .doc(email)
          .get();
      if (!consumerNumberDoc.exists) {
        msg = "Consumer number not found for the given email.";
        throw Exception();
      }

      final consumerNumber = consumerNumberDoc.data()?['cons no'];
      if (consumerNumber == null || consumerNumber.isEmpty) {
        msg = "Consumer number is empty or invalid.";
        throw Exception();
      }
      final querySnapshot = await FirebaseFirestore.instance
          .collection(consumerNumber)
          .orderBy(FieldPath.documentId)
          .get();

      final docs = querySnapshot.docs;
      List<Map<String, dynamic>> parsedData = docs.map((doc) {
        final idParts = doc.id.split('-');
        final year = int.parse(idParts[0]);
        final month = int.parse(idParts[1]);
        final units = double.parse(doc['Units Consumed']);
        final price = double.parse(doc['Amount Payable']);
        return {
          'date': DateTime(year, month),
          'units': units,
          'price': price,
        };
      }).toList();

      parsedData.sort((a, b) => a['date'].compareTo(b['date']));
      final latest6Months =
          parsedData.reversed.take(6).toList().reversed.toList();

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
                  lineTouchData:
                      LineTouchData(touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final textStyle = TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        );
                        return LineTooltipItem(
                            touchedSpot.y.toString(), textStyle);
                      }).toList();
                    },
                  )),
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
    // double nextval = pow(10, 2) * 5 + maxY;
    return maxY;
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
