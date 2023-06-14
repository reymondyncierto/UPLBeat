/*

[Catindig-Cruz-Rada-Yncierto] UPLBeat: A Health Monitoring App
CMSC 23 Final Project 2S AY 22-23
[Section B-5L Sir Aldrin Hao] 

*/

import 'user_details_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'drawer.dart';
import 'admin_edit_user.dart';
import 'admin_requests.dart';
import 'package:intl/intl.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Map<String, dynamic> userDetails = {};
  Map<String, dynamic> studentDetails = {};
  List entries = [];
  List filteredEntries = [];
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  int _selectedIndex = 0;
  DateTime? selectedDate;
  TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
                hintText: 'Find a student',
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // IconButton(
          //   icon: const Icon(Icons.calendar_today),
          //   onPressed: () async {
          //     // Show date picker
          //     final DateTime? selectedDate = await showDatePicker(
          //       context: context,
          //       initialDate: DateTime.now(),
          //       firstDate: DateTime(2020),
          //       lastDate: DateTime.now(),
          //     );

          //     if (selectedDate != null) {
          //       setState(() {
          //         searchQuery = DateFormat('yyyy-MM-dd').format(selectedDate);
          //       });
          //     }
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                searchQuery = '';
                searchController.clear();
                dateController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              // Navigates to screen that shows all Incoming Requests
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminRequests()),
              );
            },
          )
        ],
      ),
      body: _buildScreens(_selectedIndex),
      drawer: const createDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'All',
            backgroundColor: Colors.blueGrey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            label: 'Cleared',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dvr_outlined),
            label: 'Under Monitoring',
            backgroundColor: Colors.yellow,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.masks_outlined),
            label: 'Under Quarantine',
            backgroundColor: Colors.redAccent,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
        onTap: _onItemTapped,
      ),
    );
  }

  // method to return index of screes for bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print(_selectedIndex);
    });
  }

  // method to build screens for body of scaffold - depending on selected index on bottom navigation bar
  Widget _buildScreens(int index) {
    switch (index) {
      case 0:
        return ListView(shrinkWrap: true, children: [
          Column(
            children: [
              _searchField(),
              _showAllUsers(),
              const SizedBox(height: 16),
            ],
          ),
        ]);
      case 1:
        return ListView(shrinkWrap: true, children: [
          Column(
            children: [
              _searchField(),
              _showCleared(),
              const SizedBox(height: 16),
            ],
          ),
        ]);
      case 2:
        return ListView(children: [
          Column(
            children: [
              _searchField(),
              _showMonitored(),
              const SizedBox(height: 16),
            ],
          ),
        ]);
      case 3:
        return ListView(children: [
          Column(
            children: [
              _searchField(),
              _showQuarantined(),
              const SizedBox(height: 16),
            ],
          ),
        ]);
    }
    return ListView(children: [
      Column(
        children: [
          _searchField(),
          _showAllUsers(),
          const SizedBox(height: 16),
        ],
      ),
    ]);
  }
  // widget that shows all users in the collection

  Widget _showAllUsers() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('client').snapshots(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
              snapshot.data!.docs;

          // Apply search and filter
          List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredDocs = docs;

          if (searchQuery.isNotEmpty) {
            filteredDocs = filteredDocs.where((doc) {
              final name = doc["name"].toLowerCase();
              final studentNo = doc["studentNumber"].toLowerCase();
              final course = doc["course"].toLowerCase();
              final college = doc["college"].toLowerCase();

              return name.contains(searchQuery) ||
                  studentNo.contains(searchQuery) ||
                  course.contains(searchQuery) ||
                  college.contains(searchQuery);
            }).toList();
          }

          if (selectedDate != null) {
            filteredDocs = filteredDocs.where((doc) {
              final List<dynamic> entries = doc["entries"];
              for (var entry in entries) {
                final DateTime entryDate = DateTime.parse(entry["Timestamp"]);
                final DateTime selectedDateTime = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                );
                if (entryDate.year == selectedDateTime.year &&
                    entryDate.month == selectedDateTime.month &&
                    entryDate.day == selectedDateTime.day) {
                  return true;
                }
              }
              return false;
            }).toList();
          }

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
                          '${filteredDocs.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25.0,
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Current Users',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const Divider(), // Horizontal line
                      const SizedBox(height: 16.0),
                      filteredDocs.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredDocs.length,
                              itemBuilder: (_, index) {
                                final doc = filteredDocs[index];
                                final name = doc["name"];
                                final currentStatus = doc["currentStatus"];

                                return Card(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading: const Icon(
                                            Icons.person_outline_outlined),
                                        title: Text("$name"),
                                        subtitle:
                                            Text('Status: $currentStatus'),
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                UserDetailsDialog(
                                              name: name,
                                              email: doc["email"],
                                              college: doc["college"],
                                              course: doc["course"],
                                              studentNo: doc["studentNumber"],
                                              userType: doc["userType"],
                                              showUserType: true,
                                              onUserTypeChanged: (value) {
                                                FirebaseFirestore.instance
                                                    .collection('client')
                                                    .doc(doc.id)
                                                    .update(
                                                        {"userType": value});
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Text('No User'),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  // Widget that shows all users who are cleared
  Widget _showCleared() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('client')
          .where('currentStatus', isEqualTo: "Cleared")
          .snapshots(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
              snapshot.data!.docs;

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
                          '${docs.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25.0,
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Users Cleared',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const Divider(), // Horizontal line
                      const SizedBox(height: 16.0),
                      docs.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: docs.length,
                              itemBuilder: (_, index) {
                                final doc = docs[index];
                                final name = doc["name"];
                                final currentStatus = doc["currentStatus"];

                                return Card(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      ListTile(
                                        leading: const Icon(
                                          Icons.person_outline_outlined,
                                        ),
                                        title: Text("$name"),
                                        subtitle:
                                            Text('Status: $currentStatus'),
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                UserDetailsDialog(
                                              name: name,
                                              email: doc["email"],
                                              college: doc["college"],
                                              course: doc["course"],
                                              studentNo: doc["studentNumber"],
                                              userType: doc["userType"],
                                              showUserType: false,
                                              onUserTypeChanged: (value) {
                                                FirebaseFirestore.instance
                                                    .collection('client')
                                                    .doc(doc.id)
                                                    .update(
                                                        {"userType": value});
                                              },
                                            ),
                                          );
                                        },
                                        trailing: IconButton(
                                          icon: const Icon(Icons.warning),
                                          onPressed: () {
                                            _addToQuarantine(doc);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Text('No User Cleared'),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  void _addToQuarantine(DocumentSnapshot<Map<String, dynamic>> doc) async {
    try {
      await FirebaseFirestore.instance.collection('client').doc(doc.id).update({
        'currentStatus': 'Under Quarantine',
      });
    } catch (error) {
      // Handle error
      print('Error adding user to quarantine: $error');
    }
  }

  // Widget that shows all users who are Under Monitoring
  Widget _showMonitored() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('client')
          .where('currentStatus', isEqualTo: "Under Monitoring")
          .snapshots(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
              snapshot.data!.docs;

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
                          '${docs.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25.0,
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Users Under Monitoring',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const Divider(), // Horizontal line
                      const SizedBox(height: 16.0),
                      docs.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: docs.length,
                              itemBuilder: (_, index) {
                                final doc = docs[index];

                                final name = doc["name"];
                                //   final lastName = doc["lastName"];
                                final currentStatus = doc["currentStatus"];

                                return Card(
                                  child: ListTile(
                                    leading: const Icon(
                                        Icons.person_outline_outlined),
                                    title: Text("$name"),
                                    subtitle: Text('Status: $currentStatus'),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            UserDetailsDialog(
                                          name: name,
                                          email: doc["email"],
                                          college: doc["college"],
                                          course: doc["course"],
                                          studentNo: doc["studentNumber"],
                                          userType: doc["userType"],
                                          showUserType: false,
                                          onUserTypeChanged: (value) {
                                            FirebaseFirestore.instance
                                                .collection('client')
                                                .doc(doc.id)
                                                .update({"userType": value});
                                          },
                                        ),
                                      );
                                    },
                                    trailing: PopupMenuButton<String>(
                                      icon: const Icon(Icons.swap_horiz),
                                      onSelected: (value) {
                                        if (value == 'quarantine') {
                                          _moveToQuarantine(doc);
                                        } else if (value == 'endMonitoring') {
                                          _endMonitoring(doc);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return [
                                          const PopupMenuItem<String>(
                                            value: 'quarantine',
                                            child: Text('Move to Quarantine'),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'endMonitoring',
                                            child: Text('End Monitoring'),
                                          ),
                                        ];
                                      },
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Text('No User Under Monitoring'),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  void _moveToQuarantine(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    FirebaseFirestore.instance
        .collection('client')
        .doc(doc.id)
        .update({'currentStatus': 'Under Quarantine'}).then((value) {
      // Update successful
      print('User moved to quarantine');
    }).catchError((error) {
      // Error handling
      print('Failed to move user to quarantine: $error');
    });
  }

  void _endMonitoring(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    FirebaseFirestore.instance
        .collection('client')
        .doc(doc.id)
        .update({'currentStatus': 'Cleared'}).then((value) {
      // Update successful
      print('Monitoring ended for user');
    }).catchError((error) {
      // Error handling
      print('Failed to end monitoring for user: $error');
    });
  }

  Widget _showQuarantined() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('client')
          .where('currentStatus', isEqualTo: "Under Quarantine")
          .snapshots(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        } else {
          final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
              snapshot.data!.docs;

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
                          '${docs.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25.0,
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Users Under Quarantine',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const Divider(), // Horizontal line
                      const SizedBox(height: 16.0),
                      docs.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: docs.length,
                              itemBuilder: (_, index) {
                                final doc = docs[index];
                                final name = doc["name"];
                                final currentStatus = doc["currentStatus"];

                                return Card(
                                  child: ListTile(
                                    leading: const Icon(
                                        Icons.person_outline_outlined),
                                    title: Text("$name"),
                                    subtitle: Text('Status: $currentStatus'),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            UserDetailsDialog(
                                          name: name,
                                          email: doc["email"],
                                          college: doc["college"],
                                          course: doc["course"],
                                          studentNo: doc["studentNumber"],
                                          userType: doc["userType"],
                                          showUserType: false,
                                          onUserTypeChanged: (value) {
                                            FirebaseFirestore.instance
                                                .collection('client')
                                                .doc(doc.id)
                                                .update({"userType": value});
                                          },
                                        ),
                                      );
                                    },
                                    trailing: IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _clearUserFromQuarantine(doc);
                                      },
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Text('No User Under Quarantine'),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  void _clearUserFromQuarantine(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    // Assuming you have a reference to the Firestore collection
    final collectionRef = FirebaseFirestore.instance.collection('client');

    // Update the document's currentStatus field to "Cleared"
    collectionRef.doc(doc.id).update({'currentStatus': 'Cleared'}).then((_) {
      // Success
      print('User cleared from quarantine.');
    }).catchError((error) {
      // Error handling
      print('Failed to clear user from quarantine: $error');
    });
  }

  // shows dialog box of selected user's data
  Future<void> _editUser(
      QueryDocumentSnapshot<Map<String, dynamic>> userData) async {
    showDialog(
      context: context,
      builder: (context) {
        return AdminEditsUser(userData: userData);
      },
    );
  }
}
