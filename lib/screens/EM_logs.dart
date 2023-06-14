import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'drawer.dart';
import 'scan_qr_camera.dart';

class EMLogsPage extends StatefulWidget {
  const EMLogsPage({Key? key}) : super(key: key);

  @override
  _EMLogsPageState createState() => _EMLogsPageState();
}

class _EMLogsPageState extends State<EMLogsPage> {
  Map<String, dynamic> userDetails = {};
  Map<String, dynamic> studentDetails = {};
  List entries = [];
  List<Widget> filteredEntries = [];
  String searchQuery = '';
  DateTime? selectedDate;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.getCurrentUser();
    final currentUserDoc =
        FirebaseFirestore.instance.collection('client').doc(currentUser!.uid);

    try {
      final snapshot = await currentUserDoc.get();
      final data = snapshot.data();

      setState(() {
        userDetails = data!;
      });
    } catch (error) {
      print("Failed to fetch user data: $error");
    }
  }

  Widget _searchField() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: searchController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Find a student log',
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  selectedDate = pickedDate;
                });
              }
            },
            icon: Icon(Icons.calendar_today),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: Column(
        children: [
          _searchField(),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('client').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  final userDocs = snapshot.data!.docs;

                  filteredEntries = userDocs.expand((userDoc) {
                    final userData = userDoc.data() as Map<String, dynamic>;
                    final studentLogs = userData['student_logs'] as List<dynamic>;

                    return studentLogs.map((log) {
                      final location = log['location'] ?? 'Location not found';
                      final status = log['status'] ?? 'Status not found';
                      final studno = log['studno'] ?? 'Student number not found';
                      final dateTime = log['dateTime'] as Timestamp?;
                      final formattedDateTime = dateTime != null
                          ? DateTime.fromMicrosecondsSinceEpoch(dateTime.microsecondsSinceEpoch).toString()
                          : 'N/A';

                      if (selectedDate != null) {
                        final logDate = dateTime != null ? DateTime.fromMicrosecondsSinceEpoch(dateTime.microsecondsSinceEpoch) : null;
                        if (logDate == null || logDate.day != selectedDate!.day || logDate.month != selectedDate!.month || logDate.year != selectedDate!.year) {
                          return Container(); // Filter out logs not matching selected date
                        }
                      }

                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: ${userData['name']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Location: $location'),
                              Text('Status: $status'),
                              Text('Student Number: $studno'),
                              Text('Date and Time: $formattedDateTime'),
                            ],
                          ),
                        ),
                      );
                    }).toList();
                  }).toList();

                  return ListView(children: filteredEntries);
                } else {
                  return const Text('Failed to fetch user information.');
                }
              },
            ),
          ),
        ],
      ),
      drawer: const createDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const QRViewExample(),
          ));
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR'),
      ),
    );
  }
}
