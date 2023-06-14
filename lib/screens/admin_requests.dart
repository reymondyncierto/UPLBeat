import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_request_dialog.dart';

class AdminRequests extends StatefulWidget {
  const AdminRequests({super.key});

  @override
  _AdminRequestsState createState() => _AdminRequestsState();
}

class _AdminRequestsState extends State<AdminRequests> {
  final adminID = 'mFtrE9FVg0TpWoNKQwVGzq2w7Wv1';

  Map<String, dynamic> userDetails = {};
  Map<String, dynamic> studentDetails = {};
  List<Map<String, dynamic>> entries = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Incoming Requests"),
      ),
      body: ListView(children: [
        Column(
          children: [
            _showAllRequests(),
            const SizedBox(height: 16),
          ],
        ),
      ]),
    );
  }

  // shows all incoming requests from main admin
  Widget _showAllRequests() {
    final currentUserDoc =
        FirebaseFirestore.instance.collection('client').doc(adminID);

    return StreamBuilder<DocumentSnapshot>(
      stream: currentUserDoc.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasData) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;

          if (data != null) {
            entries = List.from(data['requests'] ?? []);
            //print(entries);

            return Padding(
              padding: const EdgeInsets.fromLTRB(
                  16.0, 16.0, 16.0, 0.0), // Add margin on top
              child: Column(
                children: [
                  const SizedBox(height: 8.0),

                  // Entries Container
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            '${entries.length}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25.0,
                            ),
                          ),
                        ),
                        const Center(
                          child: Text(
                            'Requests',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        const Divider(), // Horizontal line
                        const SizedBox(height: 16.0),
                        entries.isNotEmpty
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: entries.length,
                                itemBuilder: (_, index) {
                                  final doc = entries[index];

                                  return FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection('client')
                                          .doc(doc['userid'])
                                          .get(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator(); // Show a loading indicator while data is being fetched
                                        }

                                        if (snapshot.hasError) {
                                          print(
                                              "Failed to fetch student data: ${snapshot.error}");
                                          return const Text(
                                              "Failed to fetch student data");
                                        }

                                        if (snapshot.hasData) {
                                          final studentData = snapshot.data!
                                              .data() as Map<String, dynamic>;
                                          final name = studentData['name'];

                                          return Card(
                                            child: ListTile(
                                              title: Text("$name"),
                                              subtitle: Text(
                                                  "Request: ${doc['requestType']}"),
                                              onTap: () {
                                                _showRequestDetails(doc);
                                              },
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon:
                                                        const Icon(Icons.check),
                                                    onPressed: () {
                                                      //_editEntry(entry);
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.close),
                                                    onPressed: () {},
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }

                                        return const Text(
                                            "No Incoming Requests");
                                      });
                                },
                              )
                            : const Center(
                                child: Text('No entry yet'),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        }

        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _showRequestDetails(Map<String, dynamic> requestData) async {
    showDialog(
      context: context,
      builder: (context) {
        return AdminEditsUserDialog(userData: requestData);
      },
    );
  }
}
