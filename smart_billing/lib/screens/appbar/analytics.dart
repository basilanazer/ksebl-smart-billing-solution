//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
//import 'package:smart_billing/model/opn.dart';

class Analytics extends StatelessWidget {
  const Analytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // actions: [
          //   IconButton(
          //       onPressed: () {
          //         logout(context);
          //       },
          //       icon: const Icon(
          //         Icons.logout,
          //         color: Color(0xFFFD7250),
          //       )),
          //   IconButton(
          //       onPressed: () {
          //         Navigator.of(context).pushReplacementNamed('/analytics');
          //       },
          //       icon: const Icon(
          //         Icons.dashboard_outlined,
          //         color: Color(0xFFFD7250),
          //       )),
          //   IconButton(
          //       onPressed: () {},
          //       icon: const Icon(
          //         Icons.notifications_active_outlined,
          //         color: Color(0xFFFD7250),
          //       )),
          //   IconButton(
          //       onPressed: () {},
          //       icon: const Icon(
          //         Icons.person_outline,
          //         color: Color(0xFFFD7250),
          //       ))
          // ],
          title: const Text(
            'Analytics',
          )),
      body: Center(
        // child:
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 2.0,
              child: LineChart(LineChartData(lineBarsData: [
                LineChartBarData(
                    show: true,
                    spots: const [
                      FlSpot(0, 0),
                      FlSpot(2, 3),
                      FlSpot(1, 0),
                      FlSpot(5, 2),
                      FlSpot(4, 8),
                      FlSpot(3, 3),
                    ],
                    gradient: const LinearGradient(
                        colors: [Color(0xFF4D4C7D), Color(0xFFFD7250)]))
              ])),
            )
          ],
        ),
      ),
      // ),
    );
  }
}

// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';

// class LineChartExample extends StatelessWidget {
//   final List<Map<String, dynamic>> data = [
//     {'month': 'Aug', 'value': 5.0},
//     {'month': 'Sep', 'value': 3.0},
//     {'month': 'Oct', 'value': 8.0},
//     {'month': 'Nov', 'value': 6.0},
//     {'month': 'Dec', 'value': 2.0},
//     {'month': 'Jan', 'value': 7.0},
//   ]; // Replace this with your database data

//   @override
//   Widget build(BuildContext context) {
//     // Map months dynamically to x-axis indices
//     final monthMap = {for (var i = 0; i < data.length; i++) i.toDouble(): data[i]['month']};

//     return LineChart(
//       LineChartData(
//         lineBarsData: [
//           LineChartBarData(
//             spots: data.asMap().entries.map((entry) {
//               return FlSpot(entry.key.toDouble(), entry.value['value']);
//             }).toList(),
//             gradient: LinearGradient(
//               colors: [Color(0xFF4D4C7D), Color(0xFFFD7250)],
//             ),
//           ),
//         ],
//         titlesData: FlTitlesData(
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 final month = monthMap[value];
//                 return Text(month ?? '', style: const TextStyle(fontSize: 10));
//               },
//               reservedSize: 30,
//             ),
//           ),
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// https://chatgpt.com/share/6759b792-d02c-800e-89f7-7ceb233cd99e
