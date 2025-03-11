import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_billing/widgets/button.dart';
import 'package:smart_billing/widgets/inputfield.dart';

class BillHistory extends StatefulWidget {
  const BillHistory({super.key});

  @override
  State<BillHistory> createState() => _BillHistoryState();
}

class _BillHistoryState extends State<BillHistory> {
  String? consumerNumber;
  String? consumerName;
  String? consumerPhase;
  List<Map<String, dynamic>> bills = [];

  @override
  void initState() {
    super.initState();
    _fetchConsumerNumber();
  }

  Future<void> _fetchConsumerNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    if (email == null) return;

    FirebaseFirestore.instance
        .collection('consumer number')
        .doc(email)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          consumerNumber = doc['cons no'];
        });
        _fetchConsumerDetails();
      }
    });
  }

  Future<void> _fetchConsumerDetails() async {
    if (consumerNumber == null) return;

    FirebaseFirestore.instance
        .collection('consumer')
        .doc(consumerNumber!)
        .get()
        .then((doc) {
      if (doc.exists) {
        setState(() {
          consumerName = doc['name'];
          consumerPhase = doc['phase'];
        });
        _fetchBills(); // Fetch bills after getting consumer details
      }
    });
  }

  Future<void> _fetchBills() async {
    if (consumerNumber == null) return;

    FirebaseFirestore.instance.collection(consumerNumber!).get().then((snapshot) {
      List<Map<String, dynamic>> fetchedBills = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> billData = doc.data();
        billData['consumer no'] = consumerNumber;
        billData['consumer name'] = consumerName;
        billData['consumer phase'] = consumerPhase;

        fetchedBills.add({
          'id': doc.id,
          'data': billData,
        });
      }

      // Sorting the bills in descending order (latest first)
      fetchedBills.sort((a, b) => b['id'].compareTo(a['id']));

      setState(() {
        bills = fetchedBills;
      });
    });
  }


  String _formatMonthYear(String id) {
    List<String> parts = id.split('-');
    if (parts.length != 2) return id;
    Map<String, String> months = {
      '01': 'January', '02': 'February', '03': 'March',
      '04': 'April', '05': 'May', '06': 'June',
      '07': 'July', '08': 'August', '09': 'September',
      '10': 'October', '11': 'November', '12': 'December'
    };
    return "${months[parts[1]]} ${parts[0]}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Previous Bills')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bills.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: bills.length,
                      itemBuilder: (context, index) {
                        final bill = bills[index];
                        return Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 10), // Added horizontal padding for better centering
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF4D4C7D),
                          ),
                          child: Center( // Centers the content inside the Container
                            child: ListTile(
                              leading: const Icon(Icons.file_copy_outlined, color: Color(0xFFFD7250), size: 40),
                              title: Text(
                                _formatMonthYear(bill['id']),
                                style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center, // Centers the text inside the title
                              ),
                              trailing: const Icon(Icons.arrow_forward, color: Color(0xFFFD7250)),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BillDetailsPage(
                                    billData: bill['data'],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class BillDetailsPage extends StatelessWidget {
  final Map<String, dynamic> billData;

  BillDetailsPage({super.key, required this.billData});

  final List<String> fieldOrder = [
    'consumer no', 'consumer name', 
    'bill#', 'bill date', 'due date', 'disconn dt', 'load', 'consumer phase',
    'prv rd dt', 'prs rd date', 'unit', 'curr', 'prev', 'cons',
    'Fixed Charge', 'Meter Rent', 'Energy Charge', 'duty', 'FC Subsidy', 'EC Subsidy', 'total'
  ];

  final Map<String, String> fieldLabels = {
    'consumer no': 'Consumer Number', 'consumer name': 'Name',
    'bill#': 'Bill Number', 'Bill date': 'Bill Date', 'due date': 'Due Date', 'Disconn dt': 'Disconnection Date',
    'load': 'Load',  'consumer phase': 'Phase', 'prv rd dt': 'Previous Reading Date',
    'prs rd date': 'Present Reading Date', 'unit': 'Unit', 'curr': 'Current Reading',
    'prev': 'Previous Reading', 'cons': 'Consumed Units',
    'Fixed Charge': 'Fixed Charge', 'Meter Rent': 'Meter Rent',
    'Energy Charge': 'Energy Charge', 'Duty': 'Duty', 'FC Subsidy': 'FC Subsidy', 
    'EC Subsidy': 'EC Subsidy','Monthly Fuel Surcharge':'Monthly Fuel Surcharge', 'total': 'Total Amount Payable'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bill Details')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: fieldOrder.map((field) {
              return billData.containsKey(field)
                  ? InputField(
                      label: fieldLabels[field]!,
                      controller: TextEditingController(text: billData[field].toString()),
                      isEnable: false,
                    )
                  : Container();
            }).toList(),
              ),
              const SizedBox(height: 10,),
              Buttons(label: "view PDF", fn: (){})
            ]
            
          ),
        ),
      ),
    );
  }
}
