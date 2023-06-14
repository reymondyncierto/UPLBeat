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
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              hintText: 'Find a student',
              prefixIcon: Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          searchQuery = '';
                          searchController.clear();
                          dateController.clear();
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
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
            backgroundColor: Colors.orange,
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
  Widget bodyWidget;
  switch (index) {
    case 0:
      bodyWidget = ListView(
        shrinkWrap: true,
        children: [
          Column(
            children: [
              _searchField(),
              _showAllUsers(),
              const SizedBox(height: 16),
            ],
          ),
        ],
      );
      break;
    case 1:
      bodyWidget = ListView(
        shrinkWrap: true,
        children: [
          Column(
            children: [
              _searchField(),
              _showCleared(),
              const SizedBox(height: 16),
            ],
          ),
        ],
      );
      break;
    case 2:
      bodyWidget = ListView(
        children: [
          Column(
            children: [
              _searchField(),
              _showMonitored(),
              const SizedBox(height: 16),
            ],
          ),
        ],
      );
      break;
    case 3:
      bodyWidget = ListView(
        children: [
          Column(
            children: [
              _searchField(),
              _showQuarantined(),
              const SizedBox(height: 16),
            ],
          ),
        ],
      );
      break;
    default:
      bodyWidget = ListView(
        children: [
          Column(
            children: [
              _searchField(),
              _showAllUsers(),
              const SizedBox(height: 16),
            ],
          ),
        ],
      );
      break;
  }
  return bodyWidget;
}
  // widget that shows all users in the collection

Widget _showAllUsers() {
  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance.collection('client').snapshots(),
    builder: (BuildContext context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return const Center(child: Text('Error loading data'));
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

        return SingleChildScrollView(
          child: Padding(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Users',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 8.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              '${filteredDocs.length}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      if (filteredDocs.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: filteredDocs.length,
                          itemBuilder: (_, index) {
                            final doc = filteredDocs[index];
                            final name = doc["name"];
                            final currentStatus = doc["currentStatus"];

                            return Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16.0),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blueGrey,
                                  child: const Icon(Icons.person_outline_outlined, color: Colors.white,),
                                ),
                                title: Text(
                                  "$name",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
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
                                      showUserType: true,
                                      onUserTypeChanged: (value) {
                                        FirebaseFirestore.instance
                                            .collection('client')
                                            .doc(doc.id)
                                            .update({"userType": value});
                                      },
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        )
                      else
                        const Center(
                          child: Text(
                            'No User',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
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
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return const Center(child: Text('Error loading data'));
      } else {
        final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
            snapshot.data!.docs;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16.0, 16.0, 16.0, 0.0
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Users Cleared',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 8.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              '${docs.length}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
          
                      const SizedBox(height: 16.0),
                      if (docs.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          itemBuilder: (_, index) {
                            final doc = docs[index];
                            final name = doc["name"];
                            final currentStatus = doc["currentStatus"];

                            return Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16.0),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Icon(
                                    Icons.person_outline_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                subtitle: Text(
                                  'Status: $currentStatus',
                                  style: TextStyle(fontSize: 14.0),
                                ),
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
                                  icon: Icon(
                                    Icons.warning,
                                    color: Colors.yellow,
                                  ),
                                  onPressed: () {
                                    _addToQuarantine(doc);
                                  },
                                ),
                              ),
                            );
                          },
                        )
                      else
                        Center(
                          child: Text(
                            'No User Cleared',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    },
  );
}



void _addToQuarantine(DocumentSnapshot<Map<String, dynamic>> doc) async {
  try {
    // Get the document reference
    var documentReference = FirebaseFirestore.instance.collection('client').doc(doc.id);

    // Retrieve the document data
    var documentSnapshot = await documentReference.get();

    // Get the list of entries
    List<dynamic> entries = List.from(documentSnapshot.data()?['entries']);

    // Get the last entry from the list
    var lastEntry = Map<String, dynamic>.from(entries.last);
    print(lastEntry);

    // Update the last entry's status to 'Under Quarantine'
    lastEntry['status'] = 'Under Quarantine';

    // Update the last entry in the entries list
    entries[entries.length - 1] = lastEntry;

    // Update the document with the modified list
    await documentReference.update({
      'currentStatus': 'Under Quarantine',
      'entries': entries,
    });
  } catch (error) {
    // Handle error
    print('Error updating user status to "Under Quarantine": $error');
  }
}


Widget _showMonitored() {
  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance
        .collection('client')
        .where('currentStatus', isEqualTo: "Under Monitoring")
        .snapshots(),
    builder: (BuildContext context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return const Center(child: Text('Error loading data'));
      } else {
        final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
            snapshot.data!.docs;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16.0, 16.0, 16.0, 0.0
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Users Under Monitoring',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 8.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              '${docs.length}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      if (docs.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          itemBuilder: (_, index) {
                            final doc = docs[index];
                            final name = doc["name"];
                            final currentStatus = doc["currentStatus"];

                            return Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16.0),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange,
                                  child: Icon(
                                    Icons.person_outline_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                subtitle: Text(
                                  'Status: $currentStatus',
                                  style: TextStyle(fontSize: 14.0),
                                ),
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
                                  icon: Icon(
                                    Icons.swap_horiz,
                                    color: Colors.grey[700],
                                  ),
                                  onSelected: (value) {
                                    if (value == 'quarantine') {
                                      _moveToQuarantine(doc);
                                    } else if (value == 'endMonitoring') {
                                      _clearUserFromQuarantine(doc);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      PopupMenuItem<String>(
                                        value: 'quarantine',
                                        child: Text('Move to Quarantine'),
                                      ),
                                      PopupMenuItem<String>(
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
                      else
                        Center(
                          child: Text(
                            'No Users Under Monitoring',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    },
  );
}




void _moveToQuarantine(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
  try {
    final collectionRef = FirebaseFirestore.instance.collection('client');
    final currUser = collectionRef.doc(doc.id);

    final documentSnapshot = await currUser.get();
    final entries = List<dynamic>.from(documentSnapshot.data()?['entries'] ?? []);

    if (entries.isNotEmpty) {
      final lastIndex = entries.length - 1;
      final lastEntry = Map<String, dynamic>.from(entries[lastIndex]);

      final updatedEntry = {
        ...lastEntry,
        'Fever': false,
        'Feeling Feverish': false,
        'Muscle or Joint Pains': false,
        'Cough': false,
        'Colds': false,
        'Sore Throat': false,
        'Difficulty of Breathing': false,
        'Diarrhea': false,
        'Loss of Taste': false,
        'Loss of Smell': false,
        'Has Face-to-face Encounter': true,
        'status': 'Under Quarantine',
        // Add more fields to update here
      };

      entries[lastIndex] = updatedEntry;

      await currUser.update({
        'entries': entries,
        'currentStatus': 'Under Quarantine',
      });

      print('User moved to quarantine.');
    } else {
      print('User has no entries.');
    }
  } catch (error) {
    print('Failed to move user to quarantine: $error');
  }
}



Widget _showQuarantined() {
  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance
        .collection('client')
        .where('currentStatus', isEqualTo: "Under Quarantine")
        .snapshots(),
    builder: (BuildContext context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error loading data'));
      } else {
        final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
            snapshot.data!.docs;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Users Under Quarantine',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 8.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Text(
                              '${docs.length}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      if (docs.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: docs.length,
                          itemBuilder: (_, index) {
                            final doc = docs[index];
                            final name = doc["name"];
                            final currentStatus = doc["currentStatus"];

                            return Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16.0),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.redAccent,
                                  child: Icon(
                                    Icons.person_outline_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                subtitle: Text(
                                  'Status: $currentStatus',
                                  style: TextStyle(fontSize: 14.0),
                                ),
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
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    _clearUserFromQuarantine(doc);
                                  },
                                ),
                              ),
                            );
                          },
                        )
                      else
                        Center(
                          child: Text(
                            'No Users Under Quarantine',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    },
  );
}




void _clearUserFromQuarantine(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  try {
    // Assuming you have a reference to the Firestore collection
    final collectionRef = FirebaseFirestore.instance.collection('client');

    // Get the document reference for the current user
    final currUser = collectionRef.doc(doc.id);

    // Retrieve the document data
    currUser.get().then((documentSnapshot) {
      // Get the list of entries
      List<dynamic> entries = List.from(documentSnapshot.data()?['entries']);

      // Get the index of the last entry in the list
      int lastIndex = entries.length - 1;

      // Get the last entry
      Map<String, dynamic> lastEntry = Map.from(entries[lastIndex]);

      // Create a new map with updated fields
      Map<String, dynamic> updatedEntry = {
        ...lastEntry,
        'Fever': false,
        'Feeling Feverish': false,
        'Muscle or Joint Pains': false,
        'Cough': false,
        'Colds': false,
        'Sore Throat': false,
        'Difficulty of Breathing': false,
        'Diarrhea': false,
        'Loss of Taste': false,
        'Loss of Smell': false,
        'Has Face-to-face Encounter': false,
        'status': 'Cleared'
        // Add more fields to update here
      };

      // Update the last entry in the list
      entries[lastIndex] = updatedEntry;

      // Update the document with the modified last entry
      currUser.update({
        'entries': entries,
        'currentStatus': 'Cleared',
      }).then((_) {
        print('User cleared from quarantine.');
      }).catchError((error) {
        print('Failed to clear user from quarantine: $error');
      });
    });
  } catch (error) {
    print('Failed to clear user from quarantine: $error');
  }
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
