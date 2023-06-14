/*

[Catindig-Cruz-Rada-Yncierto] 
UPLBeat: A Health Monitoring App
CMSC 23 Final Project 2S AY 22-23
[Section B-5L Sir Aldrin Hao] 

*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminEditsUserDialog extends StatefulWidget {
  final Map<String, dynamic> userData;
  // final Function(Map<String, dynamic>) onUpdate;

  const AdminEditsUserDialog({super.key, required this.userData});
  //const AdminEditsUser({required this.userData, required this.onUpdate});
  @override
  _AdminEditsUserDialogState createState() => _AdminEditsUserDialogState();
}

class _AdminEditsUserDialogState extends State<AdminEditsUserDialog> {
  late bool isFever = false;
  late bool isFeelingFeverish = false;
  late bool isMuscleJointPains = false;
  late bool isCough = false;
  late bool isColds = false;
  late bool isSoreThroat = false;
  late bool isDifficultyBreathing = false;
  late bool isDiarrhea = false;
  late bool isLossOfTaste = false;
  late bool isLossOfSmell = false;
  late bool hasEncounter = false;

  // late final firstName;
  // late final lastName;
  late final currentStatus;
  late final docID;
  late Map<dynamic, dynamic> requestEntry = {};
  late Map<dynamic, dynamic> lastEntry = {};

//  String dropdownValue = 'user';

  @override
  void initState() {
    super.initState();

    docID = widget.userData['userid'];
    currentStatus = widget.userData['currentStatus'];
    requestEntry = widget.userData['editedEntry'] ?? [];

    if (requestEntry.isNotEmpty) {
      isFever = requestEntry['Fever'] ?? false;
      isFeelingFeverish = requestEntry['Feeling Feverish'] ?? false;
      isMuscleJointPains = requestEntry['Muscle or Joint Pains'] ?? false;
      isCough = requestEntry['Cough'] ?? false;
      isColds = requestEntry['Colds'] ?? false;
      isSoreThroat = requestEntry['Sore Throat'] ?? false;
      isDifficultyBreathing = requestEntry['Difficulty of Breathing'] ?? false;
      isDiarrhea = requestEntry['Diarrhea'] ?? false;
      isLossOfTaste = requestEntry['Loss of Taste'] ?? false;
      isLossOfSmell = requestEntry['Loss of Smell'] ?? false;
      hasEncounter = requestEntry['Has Face-to-face Encounter'] ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('$docID'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(),
            Text("Status: $currentStatus",
                style: TextStyle(
                  color: currentStatus == 'Cleared'
                      ? Colors.green.withOpacity(0.8)
                      : currentStatus == 'Under Monitoring'
                          ? Colors.orange.withOpacity(0.8)
                          : Colors.red.withOpacity(0.8),
                )),
            _buildEntrySwitchListTile(
              'Fever (37.8°C and above)',
              isFever,
              (value) {
                setState(() {
                  isFever = value;
                });
              },
            ),
            _buildEntrySwitchListTile(
              'Feeling Feverish',
              isFeelingFeverish,
              (value) {
                setState(() {
                  isFeelingFeverish = value;
                });
              },
            ),
            _buildEntrySwitchListTile(
                'Muscle or Joint Pains', isMuscleJointPains, (value) {
              setState(() {
                isMuscleJointPains = value;
              });
            }),
            _buildEntrySwitchListTile('Cough', isCough, (value) {
              setState(() {
                isCough = value;
              });
            }),
            _buildEntrySwitchListTile('Colds', isColds, (value) {
              setState(() {
                isColds = value;
              });
            }),
            _buildEntrySwitchListTile('Sore Throat', isSoreThroat, (value) {
              setState(() {
                isSoreThroat = value;
              });
            }),
            _buildEntrySwitchListTile(
                'Difficulty of Breathing', isDifficultyBreathing, (value) {
              setState(() {
                isDifficultyBreathing = value;
              });
            }),
            _buildEntrySwitchListTile('Diarrhea', isDiarrhea, (value) {
              setState(() {
                isDiarrhea = value;
              });
            }),
            _buildEntrySwitchListTile('Loss of Taste', isLossOfTaste, (value) {
              setState(() {
                isLossOfTaste = value;
              });
            }),
            _buildEntrySwitchListTile('Loss of Smell', isLossOfSmell, (value) {
              setState(() {
                isLossOfSmell = value;
              });
            }),
            _buildEntrySwitchListTile(
                'Has Face-to-face Encounter', hasEncounter, (value) {
              setState(() {
                hasEncounter = value;
              });
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            // updating today's entry with new data
            final currUser =
                FirebaseFirestore.instance.collection('client').doc(docID);
            final documentSnapshot = await currUser.get();
            final entries =
                List.from(documentSnapshot.data()?['entries'] ?? []);

            if (entries.isNotEmpty) {
              currUser.get().then((DocumentSnapshot snapshot) {
                if (snapshot.exists) {
                  final data = snapshot.data() as Map<String, dynamic>;
                  final dataArray = List.from(data['entries']);
                  final timestamp =
                      dataArray[dataArray.length - 1]['Timestamp'];

                  final updatedEntry = {
                    // 'Timestamp': widget.entry['Timestamp'], // Keep the original timestamp
                    'Fever': isFever,
                    'Feeling Feverish': isFeelingFeverish,
                    'Muscle or Joint Pains': isMuscleJointPains,
                    'Cough': isCough,
                    'Colds': isColds,
                    'Sore Throat': isSoreThroat,
                    'Difficulty of Breathing': isDifficultyBreathing,
                    'Diarrhea': isDiarrhea,
                    'Loss of Taste': isLossOfTaste,
                    'Loss of Smell': isLossOfSmell,
                    'Has Face-to-face Encounter': hasEncounter,
                    'Timestamp': timestamp
                  };

                  // Determine the status for the new entry
                  String status = '';

                  if (isFever ||
                      isFeelingFeverish ||
                      isMuscleJointPains ||
                      isCough ||
                      isColds ||
                      isSoreThroat ||
                      isDifficultyBreathing ||
                      isDiarrhea ||
                      isLossOfTaste ||
                      isLossOfSmell) {
                    status = 'Under Quarantine';
                  } else if (hasEncounter) {
                    status = 'Under Monitoring';
                  } else {
                    status = 'Cleared';
                  }

                  dataArray[dataArray.length - 1] = updatedEntry;

                  currUser
                      .update({'entries': dataArray, 'currentStatus': status});
                } else {
                  print('Document does not exist.');
                }
              }).catchError((error) {
                print('Error getting document: $error');
              });
            }

            // deleting request from administrator's data
            const adminID = 'mFtrE9FVg0TpWoNKQwVGzq2w7Wv1';
            final adminUser =
                FirebaseFirestore.instance.collection('client').doc(adminID);
            final adminDocumentSnapshot = await adminUser.get();
            final adminRequests =
                List.from(adminDocumentSnapshot.data()?['requests'] ?? []);

            if (adminRequests.isNotEmpty) {
              adminUser.get().then((DocumentSnapshot snapshot) {
                if (snapshot.exists) {
                  final data = snapshot.data() as Map<String, dynamic>;
                  print(data);
                  final requestsArray = List.from(data['requests']);
                  requestsArray.remove(widget.userData);
                  adminUser.update({
                    'requests': requestsArray,
                  });
                } else {
                  print('Document does not exist.');
                }
              }).catchError((error) {
                print('Error getting document: $error');
              });
            }

            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildEntrySwitchListTile(
      String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}