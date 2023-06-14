import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'admin_request_dialog.dart';

class AdminRequests extends StatefulWidget {
  const AdminRequests({super.key});

  @override
  _AdminRequestsState createState() => _AdminRequestsState();
}

class _AdminRequestsState extends State<AdminRequests> {
  final adminID = 'mnPfqvki9BQfxiwVVvxcOrYWOyk2';

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

            return Padding(
              padding: const EdgeInsets.fromLTRB(
                16.0,
                16.0,
                16.0,
                0.0,
              ), // Add margin on top
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
                                        return const CircularProgressIndicator();
                                      }

                                      if (snapshot.hasError) {
                                        print(
                                            'Failed to fetch student data: ${snapshot.error}');
                                        return const Text(
                                            'Failed to fetch student data');
                                      }

                                      if (snapshot.hasData) {
                                        final studentData = snapshot.data!
                                            .data() as Map<String, dynamic>;
                                        final name = studentData['name'];

                                        return Card(
                                          child: ListTile(
                                            title: Text('$name'),
                                            subtitle: Text(
                                                'Request: ${doc['requestType']}'),
                                            onTap: () {
                                              _showRequestDetails(doc);
                                            },
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.check),
                                                  onPressed: () {
                                                    _updateTodayEntry(
                                                        doc['userid'],
                                                        doc['editedEntry'],
                                                        index);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.close),
                                                  onPressed: () {
                                                    _removeRequest(index);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }

                                      return const Text('No Incoming Requests');
                                    },
                                  );
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

  void _removeRequest(int index) async {
    final doc = entries[index];
    final adminDocRef =
        FirebaseFirestore.instance.collection('client').doc(adminID);

    await adminDocRef.update({
      'requests': FieldValue.arrayRemove([doc]),
    });
  }

void _updateTodayEntry(
  String userId, Map<String, dynamic> editedEntry, int requestIndex) {
  final today = DateTime.now();
  final todayString = DateFormat('yyyy-MM-dd').format(today);

  final userDoc = FirebaseFirestore.instance.collection('client').doc(userId);

  userDoc.get().then((snapshot) {
    if (snapshot.exists) {
      final userData = snapshot.data() as Map<String, dynamic>;
      final entries = List<dynamic>.from(userData['entries'] ?? []);

      // Find the entry for today's date in the list
      final entryIndex = entries.length - 1;

        // Update the existing entry in the list
        final existingEntry = entries[entryIndex];

        editedEntry.forEach((key, value) {
          existingEntry[key] = value;
        });

        existingEntry['editedAt'] = DateTime.now();
      

      userDoc.update({'entries': entries}).then((_) {
        print('Today\'s entry updated successfully.');

        // Remove the specific request from the admin's request array
        final adminId = 'mnPfqvki9BQfxiwVVvxcOrYWOyk2';
        final adminDoc = FirebaseFirestore.instance.collection('client').doc(adminId);

        adminDoc.get().then((adminSnapshot) {
          if (adminSnapshot.exists) {
            final adminData = adminSnapshot.data() as Map<String, dynamic>;
            final requests = List<dynamic>.from(adminData['requests'] ?? []);

            if (requestIndex >= 0 && requestIndex < requests.length) {
              requests.removeAt(requestIndex);
              adminDoc.update({'requests': requests}).then((_) {
                print('Request removed from admin\'s requests.');
              }).catchError((error) {
                print('Failed to remove request from admin\'s requests: $error');
              });
            } else {
              print('Invalid request index.');
            }
          }
        }).catchError((error) {
          print('Failed to retrieve admin data: $error');
        });
      }).catchError((error) {
        print('Failed to update today\'s entry: $error');
      });
    }
  }).catchError((error) {
    print('Failed to retrieve user data: $error');
  });
}



  Future<void> _showRequestDetails(Map<String, dynamic> requestData) async {
  final editedEntry = Map<String, dynamic>.from(requestData['editedEntry']);

  final studentDoc = await FirebaseFirestore.instance
      .collection('client')
      .doc(requestData['userid'])
      .get();

  final studentData = studentDoc.data() as Map<String, dynamic>;
  final studentEntries = List<Map<String, dynamic>>.from(studentData['entries'] ?? []);
  final lastEntry = studentEntries.last;

  // Create a list to hold the fields with mismatched values
  final mismatchedFields = <String, dynamic>{};

  // Iterate over the editedEntry and lastEntry to find the mismatched fields
editedEntry.forEach((key, value) {
  if (lastEntry.containsKey(key) && lastEntry[key] != value ||
      !lastEntry.containsKey(key) && value != false) {
    mismatchedFields[key] = value;
  }
});



  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edited Fields',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              ListView.separated(
                shrinkWrap: true,
                itemCount: mismatchedFields.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final field = mismatchedFields.keys.elementAt(index);
                  final previousValue = lastEntry[field];
                  final currentValue = mismatchedFields[field];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Field: $field',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Previous Value: $previousValue'),
                      Text('Current Value: $currentValue'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16.0),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

}
