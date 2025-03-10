import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_billing/widgets/button.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class MeterDetectionScreen extends StatefulWidget {
  const MeterDetectionScreen(
      {super.key, required this.meterNumber, required this.consumerNumberIs});
  final String meterNumber;
  final String consumerNumberIs;
  @override
  State<MeterDetectionScreen> createState() => _MeterDetectionScreenState();
}

class _MeterDetectionScreenState extends State<MeterDetectionScreen> {
  bool meterDetectedFlag = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();
  late Interpreter _interpreter;
  late TensorImage _tensorImage;
  // ignore: unused_field
  late List<String> _labels;
  String _meterDetectionResult = "";
  int _secondsLeft = 15; // Timer starts from 15 seconds
  Timer? _timer; // Timer variable
  bool timeEnd = false;
  bool showButton = true;
  int curr = 23333;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _startTimer(); // Start countdown when screen opens
    //captureImage(); // Automatically open the camera
    fetchPreviousMonthData();
  }

  /// Start a 15-second countdown timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer?.cancel(); // Stop timer
        //Navigator.of(context).pushReplacementNamed('/dashboard'); // Redirect to dashboard
        setState(() {
          timeEnd = true;
        });
      }
    });
  }

  /// Load TFLite Model
  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset("assets/model.tflite");
      _labels = await FileUtil.loadLabels("assets/labels.txt");
      print("Model and Labels Loaded Successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  /// Capture Image
  Future<void> captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _timer?.cancel(); // Stop the timer if image is captured
      setState(() {
        showButton = false;
        _image = File(pickedFile.path);
        _meterDetectionResult = "Processing...";
      });

      _classifyImage(_image!);
    }
  }

  /// Classify Image (Check if Meter is Detected)
  Future<void> _classifyImage(File imageFile) async {
    try {
      _tensorImage = TensorImage.fromFile(imageFile);
      ImageProcessor imageProcessor = ImageProcessorBuilder()
          .add(ResizeOp(224, 224, ResizeMethod.nearestneighbour))
          .build();

      _tensorImage = imageProcessor.process(_tensorImage);

      var input = _tensorImage.buffer;
      List<List<int>> output = List.generate(1, (_) => List.filled(2, 0));

      _interpreter.run(input, output);

      int predictedIndex = output[0][0] > output[0][1] ? 0 : 1;

      setState(() {
        meterDetectedFlag = predictedIndex == 0 ? true : false;
        _meterDetectionResult = predictedIndex == 0
            ? "METER DETECTED\nProcessing Bill"
            : "UNRECOGNIZED OBJECT\nEnsure the meter is visible and TRY AGAIN.";
      });

      if (predictedIndex == 0) {
        // Not working.as route not present.
        // If meter is detected, navigate to unit reading capture screen
        // Future.delayed(const Duration(seconds: 2), () {
        //   Navigator.pushNamed(context, '/captureReading');
        // });
      }
    } catch (e) {
      print("Error classifying image: $e");
    }
  }

  // Getting amount,fc etc from website
  Future<Map<String, dynamic>?> fetchFinalAmount(int units) async {
    var url =
        Uri.parse('https://bills.kseb.in/postTariff.php'); // Correct action URL

    var response = await http.post(url, body: {
      'tariff_id': '1', // LT-1A Domestic (Required)
      'purpose_id': '15', // Domestic (Required)
      'phase': '1', // Single Phase (Fixing "Invalid Phase" error)
      'frequency': '1', // Monthly Billing (Might be required)
      'WNL': units.toString(), // User input (Consumed Units)
    });

    // print("\n📢 **Raw Response from KSEB** 📢");
    // print(response.body); // Print the full response for debugging

    if (response.statusCode == 200) {
      try {
        var jsonData = json.decode(response.body);

        if (jsonData.containsKey('result_data') &&
            jsonData['result_data']['err_flag'] == 0) {
          var tariffValues = jsonData['result_data']['tariff_values'];
          return tariffValues;
        } else {
          print("❌ Error: ${jsonData['result_data']['disp_msg']}");
          return null;
        }
      } catch (e) {
        print("❌ Invalid Response Format");
        return null;
      }
    } else {
      print("❌ Failed to fetch data");
      return null;
    }
  }

// Getting prev month data
  String prevBillDate = "--";
  String prevPaidAmt = "--";
  String prevReading = "0";
  String prevBillNo = "0";
  String dueDate = "0";
  String disconnDate = "0";
  String billDate = "0";
  Future<void> fetchPreviousMonthData() async {
    DateTime now = DateTime.now();
    String previousMonth =
        DateFormat('yyyy-MM').format(DateTime(now.year, now.month - 1));

    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection(widget.consumerNumberIs)
        .doc(previousMonth)
        .get();
    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      String prevbillDtString = data['Bill date'] ?? "--";
      DateTime prevbillDt;

      try {
        prevbillDt = DateFormat('dd/MM/yyyy').parse(prevbillDtString);
      } catch (e) {
        prevbillDt = DateTime.now(); // Fallback in case of parsing error
      }
      print("hi $prevBillDate");
      DateTime oneMonthLater =
          DateTime(prevbillDt.year, prevbillDt.month + 1, prevbillDt.day);

      DateTime futureDate1 = oneMonthLater.add(Duration(days: 10));
      DateTime futureDate2 = oneMonthLater.add(Duration(days: 15));
      setState(() {
        prevBillNo = data['bill#'] ?? "0";
        prevBillDate = data['Bill date'] ?? "--";
        prevPaidAmt = data['total'] ?? "--";
        prevReading = data['curr'] ?? "0";
        // IF BASED ON READING FROM LAST MONTH
        dueDate = DateFormat('dd/MM/yyyy').format(futureDate1);
        disconnDate = DateFormat('dd/MM/yyyy').format(futureDate2);
        billDate = DateFormat('dd/MM/yyyy').format(oneMonthLater);
      });
    }
    print(prevBillDate);
  }

// Add to database
  Future<void> addBillDataToDatabase({
    required String billDate,
    required String disconnDate,
    required String duty,
    required String ecSubsidy,
    required String energyCharge,
    required String fcSubsidy,
    required String fixedCharge,
    required String meterRent,
    required String monthlyFuelSurcharge,
    required String billNumber,
    required String cons,
    required String curr,
    required String dueDate,
    required String load,
    required String prev,
    required String prsRdDate,
    required String prvAmountPaid,
    required String prvRdDate,
    required String total,
    required String unit,
  }) async {
    // Get current yyyy-MM format
    String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());

    // Data to store
    Map<String, dynamic> billData = {
      "Bill date": billDate,
      "Disconn Dt": disconnDate,
      "Duty": duty,
      "EC Subsidy": ecSubsidy,
      "Energy Charge": energyCharge,
      "FC Subsidy": fcSubsidy,
      "Fixed Charge": fixedCharge,
      "Meter Rent": meterRent,
      "Monthly Fuel Surcharge": monthlyFuelSurcharge,
      "bill#": billNumber,
      "cons": cons,
      "curr": curr,
      "due date": dueDate,
      "load": load,
      "prev": prev,
      "prs rd date": prsRdDate,
      "prv amount paid": prvAmountPaid,
      "prv rd dt": prvRdDate,
      "total": total,
      "unit": unit,
    };

    // Firestore operation
    await FirebaseFirestore.instance
        .collection(widget.consumerNumberIs)
        .doc(currentMonth)
        .set(billData);

    print("Bill data added successfully!");
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when leaving the screen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    String todayDate = DateFormat('dd/MM/yyyy').format(today);
    // IF  BASED ON READING TAKEN TODAY
    // DateTime futureDate1 = today.add(Duration(days: 10));
    // String dueDate = DateFormat('dd/MM/yyyy').format(futureDate1);
    // DateTime futureDate2 = today.add(Duration(days: 15));
    // String disconnDate = DateFormat('dd/MM/yyyy').format(futureDate2);
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/dashboard', (route) => false);
              },
              icon: const Icon(
                Icons.home_outlined,
                color: Color(0xFFFD7250),
              ),
            ),
          ],
          title: const Text("Meter Detection"),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              // Padding issues
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(_meterDetectionResult,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    if (!timeEnd & !meterDetectedFlag)
                      Text(
                        "Time left: $_secondsLeft sec",
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      )
                    else if (timeEnd)
                      const Text(
                        "Time Limit Exceeded\nTry again...",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 20),
                    if (showButton && !timeEnd)
                      Buttons(label: "Capture Meter Image", fn: captureImage),
                    if (meterDetectedFlag) ...[
                      SizedBox(
                        height: 20,
                      ),
                      // Helpline
                      QueryAndValue(
                        query: "Customer Care",
                        value: "1912",
                      ),
                      // ✅Image
                      HeadingsForContainer(heading: "Scanned Image"),
                      EachContainer(childContainer: [
                        _image != null
                            ? Image.file(_image!, height: 250)
                            : const SizedBox(),
                      ]),

                      SizedBox(
                        height: 20,
                      ),
                      // ✅C#,✅bill no,✅meter no,✅billdate,✅due date,✅disconn date,✅category----OPT-
                      HeadingsForContainer(heading: "Details"),
                      EachContainer(childContainer: [
                        QueryAndValue(
                          query: "C#",
                          value: widget.consumerNumberIs,
                        ),
                        QueryAndValue(
                          query: "Bill No.",
                          value: "${int.parse(prevBillNo) + 1}",
                        ),
                        // QueryAndValue(
                        //   query: "Conn. Id",
                        //   value: "dbname",
                        // ),
                        // QueryAndValue(
                        //   query: "Name",
                        //   value: "dbname",
                        // ),
                        // QueryAndValue(
                        //   query: "Address",
                        //   value: "dbname",
                        // ),
                        // QueryAndValue(
                        //   query: "Status",
                        //   value: "dbname",
                        // ),
                        // QueryAndValue(
                        //   query: "Post No.",
                        //   value: "dbname",
                        // ),
                        // QueryAndValue(
                        //   query: "Transformer",
                        //   value: "dbname",
                        // ),
                        QueryAndValue(
                          query: "Meter No.",
                          value: widget.meterNumber,
                        ),
                        // QueryAndValue(
                        //   query: "Bill Area",
                        //   value: "dbname",
                        // ),
                        QueryAndValue(
                          query: "Today\'s Date",
                          value: todayDate,
                        ),
                        QueryAndValue(
                          query: "Bill Date",
                          value: billDate,
                        ),
                        QueryAndValue(
                          query: "Due Date",
                          value: dueDate,
                        ),
                        QueryAndValue(
                          query: "Disconn Dt",
                          value: disconnDate,
                        ),
                        // QueryAndValue(
                        //   query: "Tariff",
                        //   value: "dbname",
                        // ),
                        // QueryAndValue(
                        //   query: "Purpose",
                        //   value: "dbname",
                        // ),
                        QueryAndValue(
                          query: "Category",
                          value: "DOMESTIC",
                        ),
                        // QueryAndValue(
                        //   query: "S Deposit",
                        //   value: "dbname",
                        // ),
                      ]),
                      SizedBox(
                        height: 20,
                      ),
                      // previous-✅readdt,✅paiddt,✅amount
                      HeadingsForContainer(heading: "Prev. Payment"),
                      EachContainer(childContainer: [
                        QueryAndValue(
                          query: "Prev Read Dt",
                          value: "$prevBillDate",
                        ),
                        // QueryAndValue(
                        //   query: "Prev Paid Dt",
                        //   value: "$prevBillDate",
                        // ),
                        QueryAndValue(
                          query: "Prv Paid Amt",
                          value: "$prevPaidAmt",
                        ),
                      ]),
                      SizedBox(
                        height: 20,
                      ),
                      //❌ Load,
                      HeadingsForContainer(heading: "Main Meter(MM)"),
                      EachContainer(childContainer: [
                        QueryAndValue(
                          query: "Load",
                          value: "2kWh",
                        ),
                        // QueryAndValue(
                        //   query: "C Demand",
                        //   value: "dbname",
                        // ),
                        // QueryAndValue(
                        //   query: "Phase",
                        //   value: "dbname",
                        // ),
                        // QueryAndValue(
                        //   query: "Prv Rd Dt",
                        //   value: "dbname",
                        // ),
                        // QueryAndValue(
                        //   query: "Prs Rd Dt",
                        //   value: billDate,
                        // ),
                        // QueryAndValue(
                        //   query: "Mt Rd(OMF)",
                        //   value: "dbname",
                        // ),
                      ]),
                      SizedBox(
                        height: 20,
                      ),
                      // readings-✅prev,❌curr,✅cons
                      HeadingsForContainer(heading: "Readings & Cons.(MM)"),
                      EachContainer(childContainer: [
                        Table(
                          border: null,
                          children: [
                            TableRow(children: [
                              Text(
                                "Unit",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: const Color(0xFFFD7250),
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Curr",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: const Color(0xFFFD7250),
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Prev",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: const Color(0xFFFD7250),
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Cons",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: const Color(0xFFFD7250),
                                    fontWeight: FontWeight.bold),
                              ),
                              // Text(
                              //   "Avg",
                              //   style: TextStyle(
                              //       fontSize: 20,
                              //       color: const Color(0xFFFD7250),
                              //       fontWeight: FontWeight.bold),
                              // ),
                            ]),
                            TableRow(children: [
                              const Text(
                                "KWH/A/I",
                                style: TextStyle(
                                    fontSize: 17,
                                    color: const Color(0xFFFD7250),
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                curr.toString(),
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                prevReading,
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                (curr - int.parse(prevReading)).toString(),
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              // Text(
                              //   "Avg",
                              //   style: TextStyle(
                              //       fontSize: 17,
                              //       color: const Color(0xFFFD7250),
                              //       fontWeight: FontWeight.bold),
                              // ),
                            ])
                          ],
                        ),
                      ]),
                      SizedBox(
                        height: 20,
                      ),
                      // ✅Bill Amounts,✅button to add to db
                      FutureBuilder<Map<String, dynamic>?>(
                        future: fetchFinalAmount(curr -
                            int.parse(prevReading)), // Fetch bill details
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (!snapshot.hasData ||
                              snapshot.data == null) {
                            return const Text("Failed to fetch bill details");
                          }

                          var allAmounts = snapshot.data!;
                          return Column(
                            children: [
                              HeadingsForContainer(
                                  heading: "Bill Details - Amount(in ₹)"),
                              EachContainer(childContainer: [
                                QueryAndValue(
                                  query: "Energy Charges",
                                  value:
                                      "${allAmounts['EC']?['value'] ?? 'N/A'}",
                                ),
                                QueryAndValue(
                                  query: "Duty",
                                  value:
                                      "${allAmounts['ED']?['value'] ?? 'N/A'}",
                                ),
                                if (allAmounts.containsKey('FSM'))
                                  QueryAndValue(
                                    query: "Fuel Surcharge",
                                    value: "${allAmounts['FSM']['value']}",
                                  ),
                                QueryAndValue(
                                  query: "Fixed Charges",
                                  value:
                                      "${allAmounts['FC']?['value'] ?? 'N/A'}",
                                ),
                                QueryAndValue(
                                  query: "Meter Rent",
                                  value:
                                      "${allAmounts['MR']?['value'] ?? 'N/A'}",
                                ),
                                if (allAmounts.containsKey('YF'))
                                  QueryAndValue(
                                    query: "FC Subsidy",
                                    value: "${allAmounts['YF']['value']}",
                                  ),
                                if (allAmounts.containsKey('YE'))
                                  QueryAndValue(
                                    query: "EC Subsidy",
                                    value: "${allAmounts['YE']['value']}",
                                  ),
                              ]),
                              SizedBox(
                                height: 20,
                              ),
                              QueryAndValue(
                                query: "Total Bill Amount",
                                value:
                                    "${allAmounts['bill_total']?['value'] ?? 'N/A'}",
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Buttons(
                                fn: () async {
                                  await addBillDataToDatabase(
                                    billDate: billDate,
                                    disconnDate: disconnDate,
                                    duty: allAmounts['ED']['value'].toString(),
                                    ecSubsidy: allAmounts['YE']?['value']
                                            ?.toString() ??
                                        "0.0",
                                    energyCharge:
                                        allAmounts['EC']['value'].toString(),
                                    fcSubsidy: allAmounts['YF']?['value']
                                            ?.toString() ??
                                        "0.0",
                                    fixedCharge:
                                        allAmounts['FC']['value'].toString(),
                                    meterRent:
                                        allAmounts['MR']['value'].toString(),
                                    monthlyFuelSurcharge: allAmounts['FSM']
                                                ?['value']
                                            ?.toString() ??
                                        "0.0",
                                    billNumber:
                                        (int.parse(prevBillNo) + 1).toString(),
                                    cons: (curr - int.parse(prevReading))
                                        .toString(),
                                    curr: curr.toString(),
                                    dueDate: dueDate,
                                    load: "1 KW",
                                    prev: prevReading,
                                    prsRdDate: billDate,
                                    prvAmountPaid: prevPaidAmt,
                                    prvRdDate: prevBillDate,
                                    total: allAmounts['bill_total']['value']
                                        .toString(),
                                    unit: "KWH/A",
                                  );
                                  print("Data added successfully!");
                                },
                                label: "Add Bill Data",
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

class HeadingsForContainer extends StatelessWidget {
  const HeadingsForContainer({
    super.key,
    required this.heading,
  });
  final String heading;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Text(
        heading,
        style: TextStyle(
            fontSize: 20,
            color: const Color(0xFF4D4C7D),
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

class EachContainer extends StatelessWidget {
  const EachContainer({
    super.key,
    required this.childContainer,
  });
  final List<Widget> childContainer;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: childContainer,
        ),
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 4,
              blurRadius: 10,
              offset: const Offset(0, 0), // changes position of shadow
            ),
          ],
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(15)),
    );
  }
}

class QueryAndValue extends StatelessWidget {
  const QueryAndValue({
    super.key,
    required this.value,
    required this.query,
  });
  final String value;
  final String query;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          query + " :\t\t\t",
          style: TextStyle(
              fontSize: 20,
              color: const Color(0xFFFD7250),
              fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(
              fontSize: 17, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
